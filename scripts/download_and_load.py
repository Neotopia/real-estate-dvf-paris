#!/usr/bin/env python3
"""
download_and_load.py
====================================================================
Extract + Load step of the pipeline: downloads the geolocated DVF
(Demandes de Valeurs Foncières) CSV files published by Etalab, and
loads them **as-is** (no cleaning) into a raw BigQuery table using a
*load job* — which is free and works with **BigQuery Sandbox** (no
billing account required).

All cleaning, filtering, and testing is handled downstream by dbt
(see the dbt/ directory) — this script's only job is EL (Extract +
Load), so the raw data is always available to reprocess if the dbt
transformation logic changes.

Data source : https://files.data.gouv.fr/geo-dvf/latest/csv/
License     : Licence Ouverte / Open Licence (Etalab)
Scope       : Paris + petite couronne (75, 92, 93, 94).

Note on years: geo-DVF only ever publishes a *rolling* window of the last
~5 completed years (older years drop off as new ones are published), so
this script computes the default year range at run time — see
`default_years()` below — instead of hardcoding a year list that would
silently go stale.

--------------------------------------------------------------------
Prerequisites
--------------------------------------------------------------------
1. Install dependencies:
       pip install -r scripts/requirements.txt
2. Authenticate for the client library (Sandbox project is fine):
       gcloud auth application-default login
3. Copy the env template and set your project id:
       cp .env.example .env
       # then edit .env and set BQ_PROJECT_ID=your-sandbox-project-id

--------------------------------------------------------------------
Usage
--------------------------------------------------------------------
       python scripts/download_and_load.py

Configuration is read from a local .env file (see .env.example), or from
regular environment variables if you prefer to export them yourself:
       BQ_PROJECT_ID    GCP / Sandbox project id (required for load)
       BQ_DATASET       dataset name        (default: dvf_immobilier)
       BQ_RAW_TABLE     raw table name      (default: raw_mutations_idf)
       BQ_LOCATION      dataset location    (default: EU)
       DVF_YEARS        e.g. "2023 2024 2025" or a single "2024"
                        (default: last 5 completed years, computed
                        automatically — see default_years())
       DVF_DEPARTMENTS  e.g. "75"             (default: 75 92 93 94)
====================================================================
"""

from __future__ import annotations

import datetime
import os
import sys
from pathlib import Path

import pandas as pd
import requests
from dotenv import load_dotenv

# --------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------
BASE_URL = "https://files.data.gouv.fr/geo-dvf/latest/csv"

PROJECT_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = PROJECT_ROOT / "data" / "raw"

# Load variables from a local .env file, if present, into the process
# environment. Real environment variables (export'd in your shell) always
# take priority and are never overridden by .env — see python-dotenv docs.
load_dotenv(PROJECT_ROOT / ".env")

BQ_PROJECT_ID = os.environ.get("BQ_PROJECT_ID", "")
BQ_DATASET = os.environ.get("BQ_DATASET", "dvf_immobilier")
BQ_RAW_TABLE = os.environ.get("BQ_RAW_TABLE", "raw_mutations_idf")
BQ_LOCATION = os.environ.get("BQ_LOCATION", "EU")


def default_years(today: datetime.date | None = None) -> list[str]:
    """Return the last 5 *completed* years as a list of strings.

    geo-DVF is a rolling window (roughly the 5 most recent completed
    years), so this is computed relative to today rather than hardcoded.
    The current (in-progress) year is excluded by default, since it is
    usually not fully published yet. Override with DVF_YEARS in .env if
    you want a different range, or a single year (e.g. "2024").
    """
    year = (today or datetime.date.today()).year
    last_completed = year - 1
    return [str(y) for y in range(last_completed - 4, last_completed + 1)]


YEARS = os.environ.get("DVF_YEARS", " ".join(default_years())).split()
DEPARTMENTS = os.environ.get("DVF_DEPARTMENTS", "75 92 93 94").split()

# Full raw geo-DVF column list (~40 columns), kept as-is — no filtering here.
# String columns are read as "string" dtype so codes (postal, INSEE, parcel
# ids) are never mangled into numbers or lose leading zeros.
STRING_COLUMNS = [
    "id_mutation",
    "numero_disposition",
    "nature_mutation",
    "adresse_numero",
    "adresse_suffixe",
    "adresse_nom_voie",
    "adresse_code_voie",
    "code_postal",
    "code_commune",
    "nom_commune",
    "code_departement",
    "ancien_code_commune",
    "ancien_nom_commune",
    "id_parcelle",
    "ancien_id_parcelle",
    "numero_volume",
    "lot1_numero",
    "lot2_numero",
    "lot3_numero",
    "lot4_numero",
    "lot5_numero",
    "code_type_local",
    "type_local",
    "code_nature_culture",
    "nature_culture",
    "code_nature_culture_speciale",
    "nature_culture_speciale",
]


# --------------------------------------------------------------------
# 1. Download
# --------------------------------------------------------------------
def download_files() -> list[Path]:
    """Download one gzipped CSV per (year, department). Returns local paths."""
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    paths: list[Path] = []

    for year in YEARS:
        for dept in DEPARTMENTS:
            url = f"{BASE_URL}/{year}/departements/{dept}.csv.gz"
            out = DATA_DIR / f"{year}_{dept}.csv.gz"

            if out.exists():
                print(f"    skip (already present): {out.name}")
                paths.append(out)
                continue

            print(f"    fetching {url}")
            try:
                with requests.get(url, stream=True, timeout=120) as resp:
                    resp.raise_for_status()
                    with open(out, "wb") as fh:
                        for chunk in resp.iter_content(chunk_size=1 << 16):
                            fh.write(chunk)
                paths.append(out)
            except requests.RequestException as exc:
                print(f"    WARN: could not download {url} ({exc}) — skipping")
                out.unlink(missing_ok=True)

    if not paths:
        sys.exit("ERROR: no DVF files downloaded. Check network or year/dept list.")
    return paths


def read_all_raw(paths: list[Path]) -> pd.DataFrame:
    """Read every downloaded file as-is (no filtering) and concatenate them."""
    frames: list[pd.DataFrame] = []
    for path in paths:
        print(f"    reading {path.name}")
        raw = pd.read_csv(
            path,
            compression="gzip",
            dtype={c: "string" for c in STRING_COLUMNS},
            low_memory=False,
        )
        frames.append(raw)

    result = pd.concat(frames, ignore_index=True)
    print(f"==> Raw dataset: {len(result):,} rows, {len(result.columns)} columns")
    return result


# --------------------------------------------------------------------
# 2. Load into BigQuery (load job — free, Sandbox-compatible)
# --------------------------------------------------------------------
def load_to_bigquery(df: pd.DataFrame) -> None:
    from google.cloud import bigquery  # lazy import (only needed for the load step)

    client = bigquery.Client(project=BQ_PROJECT_ID)

    dataset_id = f"{BQ_PROJECT_ID}.{BQ_DATASET}"
    try:
        client.get_dataset(dataset_id)
    except Exception:
        print(f"==> Creating dataset {dataset_id} ({BQ_LOCATION})")
        ds = bigquery.Dataset(dataset_id)
        ds.location = BQ_LOCATION
        client.create_dataset(ds, exists_ok=True)

    table_id = f"{dataset_id}.{BQ_RAW_TABLE}"
    job_config = bigquery.LoadJobConfig(
        autodetect=True,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
    )

    print(f"==> Loading {len(df):,} raw rows into {table_id}")
    job = client.load_table_from_dataframe(df, table_id, job_config=job_config)
    job.result()  # wait for completion

    table = client.get_table(table_id)
    print(f"==> Done. {table.num_rows:,} rows in {table_id}")
    print("    Next step: run `dbt run` and `dbt test` (see dbt/README or main README).")


# --------------------------------------------------------------------
# Main
# --------------------------------------------------------------------
def main() -> None:
    print("==> Downloading DVF files")
    paths = download_files()

    print("==> Reading raw files (no cleaning at this stage)")
    df = read_all_raw(paths)

    if not BQ_PROJECT_ID:
        print(
            "\nBQ_PROJECT_ID is not set — skipping the BigQuery load step.\n"
            "Set it in .env (see .env.example) and re-run this script."
        )
        return

    load_to_bigquery(df)


if __name__ == "__main__":
    main()

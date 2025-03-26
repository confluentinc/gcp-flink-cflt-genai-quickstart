import os
import json
from google.cloud import bigquery
from google.oauth2 import service_account


# Load BigQuery credentials and initialize client
# Dynamically get the absolute path based on the script's directory
script_dir = os.path.dirname(os.path.abspath(__file__))
service_account_path = os.path.join(script_dir, "service-account-key.json")


credentials = service_account.Credentials.from_service_account_file(service_account_path)
client = bigquery.Client(credentials=credentials, project=credentials.project_id)


DATASET_ID = os.getenv("DATASET_ID")
DATA_DIR = "data"
UUID_FIELDS = {"DoctorID", "PatientID"}

print(f"Using BigQuery Dataset: {DATASET_ID}")


def create_table_from_json(table_name, json_file_path):
    """Creates a BigQuery table and loads JSON data into it."""
    table_id = f"{client.project}.{DATASET_ID}.{table_name}"

    # Infer schema from the first JSON record
    with open(json_file_path, "r") as f:
        sample_data = json.loads(f.readline().strip())

    schema = [
        bigquery.SchemaField(
            key,
            "STRING" if key in UUID_FIELDS else
            "INTEGER" if isinstance(value, int) else
            "FLOAT" if isinstance(value, float) else
            "BOOLEAN" if isinstance(value, bool) else
            "RECORD" if isinstance(value, dict) else "STRING",
            mode="REQUIRED"
        ) for key, value in sample_data.items()
    ]

    # Create table if it doesn't exist
    try:
        client.create_table(bigquery.Table(table_id, schema=schema))
        print(f"Table created: {table_id}")
    except Exception as e:
        print(f"Table already exists or error: {e}")

    # Ensure UUID fields are stored as strings
    with open(json_file_path, "r") as f:
        data = [json.loads(line.strip()) for line in f]

    for record in data:
        for field in UUID_FIELDS:
            if field in record:
                record[field] = str(record[field])

    # Save cleaned data to a temporary file
    temp_json_path = f"{json_file_path}.cleaned.json"
    with open(temp_json_path, "w") as f:
        for record in data:
            f.write(json.dumps(record) + "\n")

    # Load data into BigQuery
    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.NEWLINE_DELIMITED_JSON,
        write_disposition=bigquery.WriteDisposition.WRITE_TRUNCATE,
    )

    with open(temp_json_path, "rb") as source_file:
        job = client.load_table_from_file(source_file, table_id, job_config=job_config)
        job.result()  # Wait for job to complete

    print(f"Data loaded into {table_id}")
    os.remove(temp_json_path)  # Clean up temp file


# Process all JSON files in the data directory
for filename in os.listdir(DATA_DIR):
    if filename.endswith(".json"):
        create_table_from_json(os.path.splitext(filename)[0], os.path.join(DATA_DIR, filename))

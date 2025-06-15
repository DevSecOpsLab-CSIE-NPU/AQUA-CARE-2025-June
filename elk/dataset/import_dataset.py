import csv
import requests
import os
from joblib import Parallel, delayed
from tqdm import tqdm
import warnings
import urllib3
from urllib3.exceptions import InsecureRequestWarning

# Suppress only the single InsecureRequestWarning from urllib3 needed for unverified HTTPS requests
warnings.simplefilter('ignore', InsecureRequestWarning)

# Suppress InsecureRequestWarning globally for requests and urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

# Set your Elasticsearch API key and URL
ES_APIKEY = os.getenv("ES_APIKEY", "Nk5ZOGM1Y0JkVjVWNTl1REo3RXk6Y3pyTXJsX3BSdTJweUpBYlBob0VSUQ==")
ES_URL = os.getenv("ES_URL", "https://localhost:9200")
INDEX_NAME = "iot-fishdata"
CSV_FILE = "realfishdataset.csv"

headers = {
    "Authorization": f"ApiKey {ES_APIKEY}",
    "Content-Type": "application/json"
}

def create_index():
    # Optional: Define a mapping for the index
    mapping = {
        "mappings": {
            "properties": {
                "ph": {"type": "float"},
                "temperature": {"type": "float"},
                "turbidity": {"type": "float"},
                "fish": {"type": "keyword"}
            }
        }
    }
    resp = requests.put(f"{ES_URL}/{INDEX_NAME}", headers=headers, json=mapping, verify=False)
    print("Index creation response:", resp.status_code, resp.text)

def import_csv_to_es():
    with open(CSV_FILE, newline="") as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            # Convert numeric fields
            doc = {
                "ph": float(row["ph"]),
                "temperature": float(row["temperature"]),
                "turbidity": float(row["turbidity"]),
                "fish": row["fish"]
            }
            def send_request(doc):
                return requests.post(f"{ES_URL}/{INDEX_NAME}/_doc", headers=headers, json=doc, verify=False)

            # Use joblib to parallelize requests
            # Wrap the reader with tqdm for progress bar
            if not hasattr(import_csv_to_es, "pbar"):
                import_csv_to_es.pbar = tqdm(total=None, desc="Importing rows")

            results = Parallel(n_jobs=8)(delayed(send_request)(doc) for _ in range(1))
            import_csv_to_es.pbar.update(1)
            resp = results[0]
            if resp.status_code not in (200, 201):
                print(f"Failed to insert: {doc}, Response: {resp.status_code}, {resp.text}")

def main():
    create_index()
    import_csv_to_es()

if __name__ == "__main__":
    main()

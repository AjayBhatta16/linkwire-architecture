from google.oauth2 import service_account
from google.cloud import firestore

from pathlib import Path

config_path = str(Path(__file__).resolve().parent.parent)

credentials = service_account.Credentials.from_service_account_file(config_path + "/serviceAccountKey.json")

db = firestore.Client(credentials=credentials)

users_collection = db.collection("users")

users = users_collection.stream()

for user_doc in users:
    update_data = { "agreedToLatestTerms": False }

    user_doc.reference.update(update_data)
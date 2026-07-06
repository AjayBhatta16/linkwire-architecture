from google.oauth2 import service_account
from google.cloud import firestore

from pathlib import Path

config_path = str(Path(__file__).resolve().parent.parent)

credentials = service_account.Credentials.from_service_account_file(config_path + "/serviceAccountKey.json")

db = firestore.Client(credentials=credentials)

links_collection = db.collection("links")
clicks_collection = db.collection("clicks")

links = links_collection.stream()

for link_doc in links:
    link_data = link_doc.to_dict()
    display_id = link_data["displayID"]
    
    click_count = 0
    clicks = clicks_collection.where("linkID", "==", display_id).stream()
    for _ in clicks:
        click_count += 1
    
    update_data = {"clickCount": click_count}
    
    if "clicks" in link_data:
        update_data["clicks"] = firestore.DELETE_FIELD
    
    link_doc.reference.update(update_data)

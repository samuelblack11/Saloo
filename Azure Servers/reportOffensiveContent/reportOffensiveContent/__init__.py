import os
import json
from azure.storage.blob import BlobServiceClient
import azure.functions as func

def main(req: func.HttpRequest) -> func.HttpResponse:
    connection_string = os.environ.get('StorageConnectionString')  # Get connection string from environment variable
    blob_service_client = BlobServiceClient.from_connection_string(connection_string)
    
    container_name = "salooreports"  # Name of your blob container
    container_client = blob_service_client.get_container_client(container_name)
    
    data = req.get_json()  # Get the JSON data sent by the iOS app

    # Fetch the cardName and email from the data and create the blob name
    cardName = data.get('cardName')
    email = data.get('userEmail')
    recordID = data.get('recordID')
    blob_name = f"{cardName}_{email}_{recordID}.txt"  

    blob_client = container_client.get_blob_client(blob_name)
    
    blob_client.upload_blob(json.dumps(data))  # Convert the JSON data to a string and upload it to the blob
    
    return func.HttpResponse("Data received and stored in Blob Storage")

from google.cloud import storage
from openpyxl import load_workbook
import io

# Inizializza il client di Google Cloud Storage
storage_client = storage.Client.from_service_account_json('C:/UTILS/tesitriennale-4d2f1-firebase-adminsdk-2u5v6-69e53a1fdf.json')

# Ottieni il bucket
bucket = storage_client.get_bucket('tesitriennale-4d2f1.appspot.com')

# Ottieni il blob
blob = bucket.blob('errored.xlsx')

# Scarica il blob come bytes
file_bytes = blob.download_as_bytes()

# Carica il file .xlsx dai bytes
workbook = load_workbook(io.BytesIO(file_bytes))

# Seleziona il foglio desiderato (ad esempio, il primo foglio)
sheet = workbook.active

# Ottieni il contenuto della prima riga
first_row_content = [cell.value for cell in sheet[1]]

# Stampa il contenuto della prima riga
print(first_row_content)


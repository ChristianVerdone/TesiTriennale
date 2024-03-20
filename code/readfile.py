import firebase_admin
import pandas as pd
import xlrd
from firebase_admin import credentials
from google.cloud import storage
import utilsP
from utilsC import splitCel, createItemConto


def process():
    cred = credentials.Certificate('C:/UTILS/tesitriennale-4d2f1-firebase-adminsdk-2u5v6-69e53a1fdf.json')
    app = firebase_admin.initialize_app(cred, {'storageBucket': 'gs://tesitriennale-4d2f1.appspot.com'}, name='app2')
    bucket_name = 'tesitriennale-4d2f1.appspot.com'
    storage_client = storage.Client.from_service_account_json(
        'C:/UTILS/tesitriennale-4d2f1-firebase-adminsdk-2u5v6-69e53a1fdf.json')
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.get_blob('source.xls')
    file_bytes = blob.download_as_bytes()
    print(blob.name)
    wb = xlrd.open_workbook(file_contents=file_bytes, encoding_override='ISO-8859-1')
    sheet = wb.sheet_by_index(1)  # prendo il foglio di lavoro che mi interessa lavorare
    print(sheet.cell_value(0, 0))
    listItem = []
    for n in range(0, sheet.nrows):
        temp = sheet.cell_value(n, 0)
        if temp.__class__ == str:
            if sheet.cell_value(n, 0).__contains__('Codice'):
                codConto, desConto = splitCel(sheet.cell_value(n, 0))
                continue
            if sheet.cell_value(n, 0).__contains__('DATA'):
                continue
        row = sheet.row_values(n, 0)
        item = createItemConto(codConto, desConto, row, wb)
        listItem.append(item)

    utilsP.writeNewFile(listItem)
    # leggi il file xlsx in un dataframe
    df = pd.read_excel('out.xlsx', sheet_name='Sheet1')
    # Salva il DataFrame come file csv in una variabile di tipo bytes
    csv_bytes = df.to_csv(index=False).encode('utf-8')
    # Salva il file csv in Firebase Storage
    blob = bucket.blob('file.csv')
    blob.upload_from_string(csv_bytes, content_type='application/octet-stream')
    firebase_admin.delete_app(app)
    return '200 ok'

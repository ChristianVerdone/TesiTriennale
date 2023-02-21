import os
import urllib

import pandas as pd
import xlrd
import openpyxl
import io
import firebase_admin
from firebase_admin import credentials
from openpyxl.reader.excel import load_workbook
from google.cloud import storage
import utilsP
from utilsC import splitCel, createItemConto

cred = credentials.Certificate('C:/UTILS/tesitriennale-4d2f1-177be252b698.json')
firebase_admin.initialize_app(cred, {
    'storageBucket': 'gs://tesitriennale-4d2f1.appspot.com'
})

bucket_name = 'tesitriennale-4d2f1.appspot.com'
storage_client = storage.Client.from_service_account_json('C:/UTILS/tesitriennale-4d2f1-177be252b698.json')
bucket = storage_client.get_bucket(bucket_name)
blob = bucket.get_blob('CerictContiEconomici2021-copia.xls')
file_bytes = blob.download_as_bytes()
print(blob.name)
wb = xlrd.open_workbook(file_contents=file_bytes, encoding_override='ISO-8859-1')
#pd.set_option('display.width', 0)

#location = "CerictContiEconomici2021-copia.xls"  #prendo il file

#wb = xlrd.open_workbook(location)   #copio un workbook identico al file
sheet = wb.sheet_by_index(1)    #prendo il foglio di lavoro che mi interessa lavorare
print(sheet.cell_value(0,0))
listItem= []
for n in range(0, sheet.nrows):
    temp = sheet.cell_value(n,0)
    if temp.__class__ == str:
        if sheet.cell_value(n, 0).__contains__('Codice'):
            codConto, desConto = splitCel(sheet.cell_value(n, 0))
            continue
        if sheet.cell_value(n, 0).__contains__('DATA'):
            continue
    row = sheet.row_values(n,0)
    item = createItemConto(codConto, desConto, row, wb)
    listItem.append(item)

utilsP.writeNewFile(listItem)
utilsP.writeNewFileseparati(listItem)

#df = pd.read_excel("out.xlsx")
#print(df.head())
#print(df.shape)
#print(df.dtypes)
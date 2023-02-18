import pandas as pd
import xlrd

import utilsP
from utilsC import splitCel, createItemConto

pd.set_option('display.width', 0)

location = "CerictContiEconomici2021-copia.xls"  #prendo il file
wb = xlrd.open_workbook(location)   #copio un workbook identico al file
sheet = wb.sheet_by_index(1)    #prendo il foglio di lavoro che mi interessa lavorare
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

df = pd.read_excel("out.xlsx")
print(df.head())
print(df.shape)
print(df.dtypes)
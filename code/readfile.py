from itertools import count

import pandas as pd
import openpyxl
import xlrd
import xlsxwriter
from setuptools import sic
import datetime

from utilsC import splitCel, createItemConto

pd.set_option('display.width', 0)
#df = pd.read_excel("CerictContiEconomici2021-copia.xlsx", sheet_name=1)

#print(df.head())
#print(df.shape)
#print(df.dtypes)
location = "CerictContiEconomici2021-copia.xls"  #prendo il file
wb = xlrd.open_workbook(location)   #copio un workbook identico al file
sheet = wb.sheet_by_index(1)    #prendo il foglio di lavoro che mi interessa lavorare
#print(sheet.cell_value(0, 0))   #accedo alla prima cella -> suggerimento: fare un iterazione come se fosse una matrice
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
    print(row)

print(desConto)
print(codConto)

#codice per scrivere su file excel
"""
outWorkbook = xlsxwriter.Workbook("out.xls")
outSheet = outWorkbook.add_worksheet()
Name = ["John"]
Salary = [12000]
outSheet.write("A1", "Names")
outSheet.write("B1", "sal")
outSheet.write(1, 0, Name[0])
outSheet.write(1, 1, Salary[0])
outWorkbook.close()
"""

#data = pd.read_csv("Cerict Conti Economici 2021.csv", sep=';')
#print(data.head())
#print(data.shape)
#print(data.dtypes)
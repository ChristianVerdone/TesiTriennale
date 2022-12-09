import pandas as pd
import openpyxl
import xlrd
import xlsxwriter
from setuptools import sic

from utilsC import splitCel


pd.set_option('display.width', 0)
#df = pd.read_excel("CerictContiEconomici2021-copia.xlsx", sheet_name=1)

#print(df.head())
#print(df.shape)
#print(df.dtypes)
location = "CerictContiEconomici2021-copia.xls"  #prendo il file
wb = xlrd.open_workbook(location)   #copio un workbook identico al file
sheet = wb.sheet_by_index(1)    #prendo il foglio di lavoro che mi interessa lavorare
print(sheet.cell_value(0, 0))   #accedo alla prima cella -> suggerimento: fare un iterazione come se fosse una matrice
"""list= splitCel(sheet.cell_value(0, 0))
print(list)
codConto= list[0]
print(codConto)
list = list.remove(codConto)
descConto = ''.join(list)
print(descConto)"""
#codice per scrivere su file excel
"""
outWorkbook = xlsxwriter.Workbook("out.xlsx")
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
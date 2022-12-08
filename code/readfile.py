import pandas as pd
import openpyxl
import xlrd
import xlsxwriter

pd.set_option('display.width', 0)
#df = pd.read_excel("CerictContiEconomici2021-copia.xlsx", sheet_name=1)

#print(df.head())
#print(df.shape)
#print(df.dtypes)
location = "CerictContiEconomici2021-copia.xls"
wb = xlrd.open_workbook(location)
sheet = wb.sheet_by_index(1)
print(sheet.cell_value(0, 0))


outWorkbook = xlsxwriter.Workbook("out.xlsx")
outSheet = outWorkbook.add_worksheet()
Name = ["John"]
Salary = [12000]
outSheet.write("A1", "Names")
outSheet.write("B1", "sal")
outSheet.write(1, 0, Name[0])
outSheet.write(1, 1, Salary[0])
outWorkbook.close()

#data = pd.read_csv("Cerict Conti Economici 2021.csv", sep=';')
#print(data.head())
#print(data.shape)
#print(data.dtypes)
import xlrd

from utilsP import ItemConto
import datetime
def splitCel (stringa):
    list = stringa.split()
    codConto = list[2]
    desConto = ''
    for n in range(3, len(list)):
        desConto = desConto + list[n] + ' '
    return codConto, desConto

def createItemConto(codC, des, row, wb):
    dataOp=datetime.datetime(*xlrd.xldate_as_tuple(row[0], wb.datemode)).strftime("%d/%m/%Y")
    cod=row[1]
    desOp = row[2]
    numDoc = row[3]
    dataDoc = datetime.datetime(*xlrd.xldate_as_tuple(row[4], wb.datemode)).strftime("%d/%m/%Y")
    numFat = row[5]
    if row[6] :
        temp = row[6]
        if isinstance(temp, float):
            importo = temp
            temp = 0
        else:
            temp = row[6].strip()
            importo = temp[0]
            temp = 0
    elif row[7]:
        temp = row[7]
        if isinstance(temp, float):
            importo = -temp
            temp = 0
        else:
            temp = row[7].strip()
            x= str(temp[0])
            importo = float(x)
            temp = 0
    saldo = row[8]
    contr = row[9]
    item= ItemConto.ItemConto(codC, des, dataOp, cod, desOp, numDoc, dataDoc, numFat, importo, saldo, contr)
    print(item)
    return item
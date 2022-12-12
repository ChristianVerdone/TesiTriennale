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

def createItemConto(cod, des, row, wb):
    print(row[0])
    dataOp=datetime.datetime(*xlrd.xldate_as_tuple(row[0], wb.datemode)).strftime("%d/%m/%Y")
    print(dataOp)
    item= ItemConto.__init__(cod,des,dataOp)
    return item
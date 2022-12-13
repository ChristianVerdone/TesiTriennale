import xlrd

from utilsP import ItemConto
import datetime
def splitCel (stringa):
    list = stringa.split() #Elimino gli spazi dal contenuto della cella "stringa"
    codConto = list[2] #vi
    desConto = ''
    for n in range(3, len(list)):
        desConto = desConto + list[n] + ' '
    return codConto, desConto

def createItemConto(codC, des, row, wb):
    dataOp = datetime.datetime(*xlrd.xldate_as_tuple(row[0], wb.datemode)).strftime("%d/%m/%Y")
    cod = row[1]
    desOp = row[2]
    numDoc = row[3]
    dataDoc = datetime.datetime(*xlrd.xldate_as_tuple(row[4], wb.datemode)).strftime("%d/%m/%Y")
    numFat = row[5]
    if not row[6] and not row[7]:
        importo = 0
    if row[6]:
        temp = row[6]
        print(temp)
        if isinstance(temp, float):
            importo = temp
            temp = 0
            print(importo)
        else:
            temp = row[6].strip().replace('.','').replace(',','.')
            x = str(temp)
            print('x ',x)
            importo = float(x)
            temp = 0
            print(importo)
    elif row[7]:
        temp = row[7]
        print(temp)
        if isinstance(temp, float):
            importo = -temp
            temp = 0
            print(importo)
        else:
            temp = row[7].strip().replace('.','').replace(',','.')
            x = str(temp)
            importo = -float(x)
            temp = 0
            print(importo)
    saldo = row[8]
    contr = row[9]
    print(codC, ' ', dataOp, ' ', importo)
    item = ItemConto(codC, des, dataOp, cod, desOp, numDoc, dataDoc, numFat, importo, saldo, contr)
    print(item)

    #codC, des, dataOp, cod, desOp, numDoc, dataDoc, numFat, importo, saldo, contr = None

    return item
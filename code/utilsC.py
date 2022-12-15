import xlrd

from utilsP import ItemConto
import datetime
def splitCel (stringa):
    list = stringa.split()  #Elimino gli spazi dal contenuto della cella "stringa"
    codConto = list[2]  #visto che la cella da dividere ha sempre la stessa costruzione, il codice contro è in 3
    desConto = ''   #per la descrizione del conto mi basta unire tutte le stringe successive al codice conto
    for n in range(3, len(list)):
        desConto = desConto + list[n] + ' '
    return codConto, desConto

def createItemConto(codC, des, row, wb):
    dataOp = datetime.datetime(*xlrd.xldate_as_tuple(row[0], wb.datemode)).strftime("%d/%m/%Y") #funzione che cattura la data
    cod = row[1]    #codice operazione
    desOp = row[2]  #descrizione dell'operazione
    numDoc = row[3] #numero che indica il documento
    dataDoc = datetime.datetime(*xlrd.xldate_as_tuple(row[4], wb.datemode)).strftime("%d/%m/%Y")    #data di documentazione
    numFat = row[5] #numero della fattura
    if not row[6] and not row[7]:   #per la costruzione dell'importo osservo le colonne "dare" e "avere", importo sarà
        importo = 0                 #positivo se il float sarà sulla colonna dare altrimenti sarà negativo.
    if row[6]:
        temp = row[6]
        if isinstance(temp, float):
            importo = temp
            temp = 0
        else:
            temp = row[6].strip().replace('.','').replace(',','.')
            x = str(temp)
            importo = float(x)
            temp = 0
    elif row[7]:
        temp = row[7]
        print(temp)
        if isinstance(temp, float):
            importo = -temp
            temp = 0
        else:
            temp = row[7].strip().replace('.','').replace(',','.')
            x = str(temp)
            importo = -float(x)
            temp = 0
    saldo = row[8]  #il saldo del conto per ogni operazione
    contr = row[9]  #la contropartita dell'operazione
    item = ItemConto(codC, des, dataOp, cod, desOp, numDoc, dataDoc, numFat, importo, saldo, contr)
    return item
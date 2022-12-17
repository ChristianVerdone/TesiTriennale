import xlsxwriter


class ItemConto:
    def __init__(self, codConto, descrConto, dataOp, COD, descrOperazione, numDoc,
                dataDoc, numFattura, importo, saldo, contropartita):
        self.codConto = codConto
        self.descrConto = descrConto
        self.dataOp = dataOp
        self.COD = COD
        self.descrOperazione = descrOperazione
        self.numDoc = numDoc
        self.dataDoc = dataDoc
        self.numFattura = numFattura
        #self.dare = dare
        #self.avere = avere
        self.importo = importo
        self.saldo = saldo
        self.contropartita = contropartita
        #self.costiDirAttEconomiche = None
        #self.costiDirAttNonEconomiche = None

    #Getter
    def getCodiceConto(self):
        return self.codConto
    def getDescrizioneConto(self):
        return self.descrConto
    def getDataOperazione(self):
        return self.dataOp
    def getCodice(self):
        return self.COD
    def getDescrizioneOperazione(self):
        return self.descrOperazione
    def getNumeroDocumento(self):
        return self.numDoc
    def getDataDocumento(self):
        return self.dataDoc
    def getNumFattura(self):
        return self.numFattura
    def getImporto(self):
        return self.importo
    def getSaldo(self):
        return self.saldo
    def getContropartita(self):
        return self.contropartita


    """
    def getAvere(self):
        return self.avere
    def getDare(self):
        return self.dare
    def getCosti_Diretti_Attività_Economiche(self):
        return self.costiDirAttEconomiche
    def getCosti_Diretti_Attività_Non_Economiche(self):
        return self.costiDirAttNonEconomiche
    """


def writeNewFile(listItem):
    outWorkbook = xlsxwriter.Workbook("out.xlsx")
    outSheet = outWorkbook.add_worksheet()

    outSheet.write(0, 0, "Codice Conto")
    outSheet.write(0, 1, "Descrizione conto")
    outSheet.write(0, 2, "Data operazione")
    outSheet.write(0, 3, "COD")
    outSheet.write(0, 4, "Descrizione operazione")
    outSheet.write(0, 5, "Numero documento")
    outSheet.write(0, 6, "Data documento")
    outSheet.write(0, 7, "Numero Fattura")
    outSheet.write(0, 8, "Importo")
    outSheet.write(0, 9, "Saldo")
    outSheet.write(0, 10, "Contropartita")

    for i in range(len(listItem)):
        outSheet.write(i + 1, 0, listItem[i].getCodiceConto())
        outSheet.write(i + 1, 1, listItem[i].getDescrizioneConto())
        outSheet.write(i + 1, 2, listItem[i].getDataOperazione())
        outSheet.write(i + 1, 3, listItem[i].getCodice())
        outSheet.write(i + 1, 4, listItem[i].getDescrizioneOperazione())
        outSheet.write(i + 1, 5, listItem[i].getNumeroDocumento())
        outSheet.write(i + 1, 6, listItem[i].getDataDocumento())
        outSheet.write(i + 1, 7, listItem[i].getNumFattura())
        outSheet.write(i + 1, 8, listItem[i].getImporto())
        outSheet.write(i + 1, 9, listItem[i].getSaldo())
        outSheet.write(i + 1, 10, listItem[i].getContropartita())
    outWorkbook.close()
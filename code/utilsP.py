class ItemConto:
    def __int__(self, codConto, descrConto, dataOp, COD, descrOperazione, numDoc,
                dataDoc, num, importo, saldo, contropartita):
        self.codConto = codConto
        self.descrConto = descrConto
        self.dataOp = dataOp
        self.COD = COD
        self.descrOperazione = descrOperazione
        self.numDoc = numDoc
        self.dataDoc = dataDoc
        self.num = num
        #self.dare = dare
        #self.avere = avere
        self.importo = importo
        self.saldo = saldo
        self.contropartita = contropartita
        self.costiDirAttEconomiche = None
        self.costiDirAttNonEconomiche = None

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
    def getNumero(self):
        return self.num
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



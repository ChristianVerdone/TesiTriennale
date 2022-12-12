class ItemConto:
    def __int__(self, codConto, descrConto, dataOp, COD, descrOperazione, numDoc,
                dataDoc, num, dare , avere, saldo, contropartita):
        self.codConto = codConto
        self.descrConto = descrConto
        self.dataOp = dataOp
        self.COD = COD
        self.descrOperazione = descrOperazione
        self.numDoc = numDoc
        self.dataDoc = dataDoc
        self.num = num
        self.dare = dare
        self.avere = avere
        self.saldo = saldo
        self.contropartita = contropartita
        self.importo = None
        self.costiDirAttEconomiche = None
        self.costiDirAttNonEconomiche = None


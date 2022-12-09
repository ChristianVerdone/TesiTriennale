
def splitCel (stringa):
    list = stringa.split()
    list.remove('Codice')
    list.remove( 'conto:')
    return list
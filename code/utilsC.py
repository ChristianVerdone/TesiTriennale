
def splitCel (stringa):
    list = stringa.split()
    codConto = list[2]
    desConto = ''
    for n in range(3, len(list)):
        desConto = desConto + list[n] + ' '
    return codConto, desConto
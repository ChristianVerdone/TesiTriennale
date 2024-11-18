import firebase_admin
from firebase_admin import credentials, firestore
import pandas as pd

# Carica le credenziali Firebase
cred = credentials.Certificate("C:/UTILS/tesitriennale-4d2f1-firebase-adminsdk-2u5v6-69e53a1fdf.json")
firebase_admin.initialize_app(cred)

# Connettiti al database Firestore
db = firestore.client()

# Leggi il file Excel, specificando solo le colonne da importare
file_path = 'brogliaccio_iva_ord09202905.xlsx'
use_cols = [
    'Data Operazione', 'Data Documento', 'Numero Documento',
    'Ragione Sociale', 'Codice Fiscale', 'Partita IVA', 'Causale Testata',
    'Annotazioni', 'Codice Conto', 'Descrizione Conto', 'Dare', 'Avere'
]
excel_data = pd.read_excel(file_path, usecols=use_cols)

# Filtra i dati per includere solo i conti che iniziano con '8' o '9' ed escludere la causale 225
filtered_data = excel_data[
    excel_data['Codice Conto'].astype(str).str.startswith(('8', '9')) &  # Conti che iniziano con '8' o '9'
    (excel_data['Causale Testata'] != 225)                               # Escludi causale 225
]

# Per ogni riga del file Excel filtrato, carica i dati in Firestore
for index, row in filtered_data.iterrows():
    # Ottieni il codice conto per identificare il documento principale
    codice_conto = row['Codice Conto']

    # Crea il riferimento al documento del codice conto
    conto_ref = db.collection('conti-2023').document(codice_conto)

    # Imposta il campo 'Descrizione Conto' nel documento principale del conto (merge evita sovrascritture)
    conto_ref.set({'Descrizione conto': row['Descrizione Conto']}, merge=True)

    # Crea la sottocollezione 'lineeConto' all'interno del documento del codice conto
    linee_conto_ref = conto_ref.collection('lineeConto')

    # Genera un ID unico per ogni riga/documento nella sottocollezione
    line_id = f"{codice_conto}_line_{index:03d}"

    # Converte la riga in un dizionario
    line_data = row.to_dict()

    # Rinomina la colonna 'Ragione Sociale' in 'Contropartita'
    line_data['Contropartita'] = line_data.pop('Ragione Sociale')
    line_data['Descrizione operazione'] = line_data.pop('Annotazioni')

    # Calcola il campo 'Importo' come positivo per 'Dare' e negativo per 'Avere'
    dare = row['Dare'] if not pd.isna(row['Dare']) else 0
    avere = row['Avere'] if not pd.isna(row['Avere']) else 0
    line_data['Importo'] = dare - avere

    # Rimuove le colonne 'Dare' e 'Avere'
    del line_data['Dare']
    del line_data['Avere']

    # Aggiunge le nuove colonne con i valori specificati
    line_data['Attività economiche'] = False
    line_data['Attività non economiche'] = False
    line_data['Costi Diretti'] = False
    line_data['Costi Indiretti'] = True
    line_data['Codice progetto'] = ''

    # Carica la riga come un documento nella sottocollezione
    linee_conto_ref.document(line_id).set(line_data, merge=True)

print("Dati filtrati e caricati correttamente in Firestore con la colonna 'Contropartita' e l'Importo combinato.")

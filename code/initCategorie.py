import firebase_admin
from firebase_admin import credentials, firestore

# Carica le credenziali Firebase
cred = credentials.Certificate("C:/UTILS/tesitriennale-4d2f1-firebase-adminsdk-2u5v6-69e53a1fdf.json")
firebase_admin.initialize_app(cred)

# Connettiti al database Firestore
db = firestore.client()

# Definisci le categorie e gli array di conti associati
categorie_conti = {
    "Ammortamenti": [
        "822003", "822005", "822009", "822010", "822013", "822015", "826004", "822029",
        "822042", "822043", "822044", "822045", "822046", "822047", "822048", "822049",
    ],
    "God beni terzi": [
        "812000"
    ],
    "Materie Prime": [
        "801010", "811011", "811024", "801056"
    ],
    "Oneri diversi": [
        "811000", "814005", "814010", "820002", "820006", "821005", "821006", "820007", "820009", "820010", "821000",
        "821003", "836001", "836004", "837010", "838003", "838004", "838005", "838012", "846001", "846005",
        "846007", "846008", "846009", "835001", "835006", "836003", "838008", "840004"
    ],
    "Oneri finanziari": [
        "833000", "833006", "833011", "836002", "909003", "911008"
    ],
    "Personale": [
        "804000", "804002","804003", "804004", "804023", "804024", "806004", "806006", "806008", "807000", "808000",
        "807002"
    ],
    "Servizi": [
        "801009", "810000", "801031", "804010", "809005", "809006", "809020", "811013",
        "814000", "814001", "814006", "814004", "814007", "814021", "814027", "818014",
        "814024", "816000", "816019", "817000", "818000", "819000", "803001", "818008"
    ],
    "Valore della Produzione": [
        "916005", "916021", "912002", "912003", "912006", "911003", "911016", "916004"
    ]
}

# Itera sulle categorie e sui conti associati
for categoria, conti in categorie_conti.items():
    # Riferimento al documento di categoria nella collezione 'categorie-2023'
    categoria_ref = db.collection('categorie-2023').document(categoria)

    # Crea l'array di riferimenti per i conti
    conti_references = [db.document(f'conti-2023/{conto}') for conto in conti]

    # Imposta il documento della categoria con l'array 'Conti' e il riepilogo 'riepilogoCat'
    categoria_ref.set({
        "Conti": conti_references
    }, merge=True)

print("Documenti di categoria e riferimenti ai conti inseriti correttamente in Firestore.")

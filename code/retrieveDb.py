import firebase_admin
from firebase_admin import credentials, firestore
import json
import csv


class FirebaseCollectionDownloader:
    def __init__(self, cred_path):
        # Initialize Firebase app
        self.cred = credentials.Certificate(cred_path)
        self.app = firebase_admin.initialize_app(self.cred)
        self.db = firestore.client()

    def download_collection(self, collection_name, output_file):
        # Fetch the collection
        collection_ref = self.db.collection(collection_name)
        docs = collection_ref.stream()

        # Convert documents to list of dictionaries with document reference as string
        collection_data = []
        for doc in docs:
            doc_dict = doc.to_dict()
            # print(doc_dict)
            # Convert DocumentReference objects to their string paths
            doc_dict['doc_name'] = doc.id
            doc_dict['Conti'] = [ref.path for ref in doc_dict['Conti']]
            collection_data.append(doc_dict)

        # Save the list of dictionaries to a CSV file
        with open(output_file, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=collection_data[0].keys())
            writer.writeheader()
            for data in collection_data:
                writer.writerow(data)

    def download_collection2(self, collection_name, output_file):
        # Fetch the collection
        global linee_conto_ref
        collection_ref = self.db.collection(collection_name)
        docs = collection_ref.stream()

        # Convert documents to list of dictionaries with document reference as string and document name
        collection_data = []
        for doc in docs:
            doc_dict = doc.to_dict()
            doc_dict['doc_id'] = doc.id
            # doc_dict['doc_ref'] = doc.reference.path

            # Fetch the subcollection 'lineeConto'
            linee_conto_ref = doc.reference.collection('lineeConto')
            linee_conto_docs = linee_conto_ref.stream()
            doc_dict['lineeConto'] = [linea_doc.to_dict() for linea_doc in linee_conto_docs]

            collection_data.append(doc_dict)
        # Prepare to write to the text file
        with open(output_file, 'w') as f:
            for doc in docs:
                doc_dict = doc.to_dict()
                doc_dict['doc_id'] = doc.id

                # Fetch the subcollection 'lineeConto'
                linee_conto_docs = linee_conto_ref.stream()

                # Sum the 'importo' field for each 'linea_doc'
                total_importo = sum(linea_doc.to_dict().get('importo', 0) for linea_doc in linee_conto_docs)

                # Write the document name and the sum of 'importo' to the text file
                f.write('Document: ' + doc.id + ', Total Importo: ' + total_importo + '\n')

        # Save the list of dictionaries to a JSON file
        with open(output_file, 'w') as f:
            json.dump(collection_data, f, indent=4)


# Example usage:
downloader = FirebaseCollectionDownloader('C:/UTILS/tesitriennale-4d2f1-firebase-adminsdk-2u5v6-69e53a1fdf.json')
downloader.download_collection('categorie', 'categorie.csv')
downloader.download_collection2('conti', 'conti.csv')

import firebase_admin
from firebase_admin import credentials, firestore
import json
import csv

from numpy import double


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

    def download_collection3(self, collection_name, output_file):
        # Fetch the collection
        collection_ref = self.db.collection(collection_name)
        docs = collection_ref.stream()

        # Convert documents to list of dictionaries with document reference as string
        collection_data = []
        for doc in docs:
            doc_dict = doc.to_dict()
            # Convert DocumentReference objects to their string paths
            if doc.id != 'DefaultProject':
                doc_dict['doc_name'] = doc.id

                # Sum the values inside 'Costi Indiretti' and 'Costi Diretti' excluding 'Oneri finanziari'
                costi_indiretti_sum = sum(double(value) for key, value in doc_dict['Costi Indiretti'].items() if key != 'Oneri finanziari')
                costi_diretti_sum = sum(double(value) for key, value in doc_dict['Costi Diretti'].items() if key != 'Oneri finanziari')

                # Save the sums in the dictionary fields
                doc_dict['Costi Indiretti Somma'] = costi_indiretti_sum
                doc_dict['Costi Diretti Somma'] = costi_diretti_sum

                collection_data.append(doc_dict)

        # Save the list of dictionaries to a CSV file with ';' as the separator
        with open(output_file, 'w', newline='') as f:
            writer = csv.DictWriter(f, fieldnames=collection_data[0].keys(), delimiter=';')
            writer.writeheader()
            for data in collection_data:
                writer.writerow(data)

    def download_collection4(self, collection_name, output_file):
        # Fetch the collection
        collection_ref = self.db.collection(collection_name)
        docs = collection_ref.stream()

        # Convert documents to list of dictionaries with document reference as string
        collection_data = []
        for doc in docs:
            doc_dict = doc.to_dict()

            # Filter for "personale" category
            if doc.id == 'Personale':
                doc_dict['doc_name'] = doc.id

                # Initialize the total sum for Project Amounts
                total_project_amounts_sum = 0

                # Access the 'Conti' field
                if 'Conti' in doc_dict:
                    for account_ref in doc_dict['Conti']:
                        account_doc = account_ref.get().to_dict()

                        # Check if 'Project Amounts' key exists in the account document
                        if 'Project Amounts' in account_doc:
                            # Calculate the sum of the values in the 'Project Amounts' map
                            project_amounts_sum = sum(double(value) for value in account_doc['Project Amounts'].values())
                            total_project_amounts_sum += project_amounts_sum

                # Calculate the difference between 'importo' and the total sum of 'Project Amounts'
                importo = double(doc_dict.get('importo', 0))
                difference = importo - total_project_amounts_sum

                # Save the difference in the dictionary
                doc_dict['Difference'] = difference

                collection_data.append(doc_dict)

        # Check if collection_data is not empty
        if collection_data:
            # Save the list of dictionaries to a CSV file with ';' as the separator
            with open(output_file, 'w', newline='') as f:
                writer = csv.DictWriter(f, fieldnames=collection_data[0].keys(), delimiter=';')
                writer.writeheader()
                for data in collection_data:
                    writer.writerow(data)
        else:
            print("No documents found in the 'personale' category.")


# Example usage:
downloader = FirebaseCollectionDownloader('C:/UTILS/tesitriennale-4d2f1-firebase-adminsdk-2u5v6-69e53a1fdf.json')
#downloader.download_collection('categorie', 'categorie.csv')
#downloader.download_collection2('conti', 'conti.csv')
downloader.download_collection3('progetti', 'progetti.csv')
#downloader.download_collection4('categorie', 'personale.csv')

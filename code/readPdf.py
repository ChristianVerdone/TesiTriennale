from pdf2image import convert_from_path
import pytesseract


def read_pdf_with_ocr(file_path):
    # Converti le pagine del PDF in immagini
    pages = convert_from_path(file_path)

    text = ""
    for page in pages:
        # Esegui l'OCR sulla pagina
        page_text = pytesseract.image_to_string(page)
        text += page_text

    return text


text = read_pdf_with_ocr('2022.pdf')
print(text)

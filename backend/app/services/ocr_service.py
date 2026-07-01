import logging

logger = logging.getLogger(__name__)

class OCRService:
    def extract_text_from_file(self, file_bytes: bytes, filename: str) -> str:
        """
        Attempts to read plain text.
        For images, return placeholder telling backend to use Gemini Multimodal.
        """
        ext = filename.split(".")[-1].lower()
        
        if ext in ["txt"]:
            try:
                return file_bytes.decode("utf-8")
            except Exception as e:
                logger.error(f"Error decoding text file: {e}")
                return ""
        elif ext in ["pdf"]:
            # Simple text PDF mock extraction or keyword-matching
            # In a real environment, we'd use PyPDF2 / pdfplumber.
            # Returning string to indicate a PDF file structure.
            return "[PDF Document - Multimodal Content]"
        else:
            # For images, we will pass the bytes directly to Gemini
            return "[Image File - OCR processed via Gemini Multimodal API]"

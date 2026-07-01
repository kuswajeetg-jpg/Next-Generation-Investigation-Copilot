import os
import logging
from typing import Dict, Any, List
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from app.services.gemini_service import GeminiService
from app.services.ocr_service import OCRService
from app.services.audio_service import AudioService
from app.config import settings

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="PoliceMind AI Backend API",
    description="Next Generation Investigation Copilot Backend services.",
    version="1.0.0"
)

# CORS configurations for Flutter Client integration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize Services
gemini_service = GeminiService()
ocr_service = OCRService()
audio_service = AudioService()

# Request schemas
class ContradictionRequest(BaseModel):
    statement_a: Dict[str, Any]
    statement_b: Dict[str, Any]

class TimelineRequest(BaseModel):
    case_text: str

class LinkMapRequest(BaseModel):
    case_details: str

class SuggestionsRequest(BaseModel):
    case_summary: str
    missing_info: List[str]

class ReconstructionRequest(BaseModel):
    statements: List[str]
    cctv_metadata: List[str]


@app.get("/", response_class=HTMLResponse)
def read_root():
    """
    Serve the interactive PoliceMind AI Web Client Dashboard.
    """
    static_file_path = os.path.join(os.path.dirname(__file__), "static", "index.html")
    if os.path.exists(static_file_path):
        with open(static_file_path, "r", encoding="utf-8") as f:
            return HTMLResponse(content=f.read(), status_code=200)
    
    # Fallback status JSON if file is missing
    return HTMLResponse(content="""
        <html>
            <body style="font-family: sans-serif; background: #0b0f19; color: #f8fafc; padding: 40px; text-align: center;">
                <h2>PoliceMind AI API Online</h2>
                <p>Version: 1.0.0</p>
                <p style="color: #94a3b8">Note: app/static/index.html not found</p>
            </body>
        </html>
    """, status_code=200)


@app.post("/api/v1/extract-fir")
async def extract_fir(file: UploadFile = File(...)):
    """
    Extract structured case information, suspect profiles, 
    and victim data from uploaded FIR images/documents.
    """
    try:
        file_bytes = await file.read()
        filename = file.filename or "fir_document.pdf"
        
        # Check MIME type
        content_type = file.content_type or ""
        is_image = "image" in content_type or filename.split(".")[-1].lower() in ["jpg", "jpeg", "png"]
        
        if is_image:
            # Pass image bytes directly to Gemini Multimodal
            logger.info("Processing FIR as an image using Gemini Multimodal...")
            extracted_info = gemini_service.extract_fir_details(
                fir_text="",
                image_bytes=file_bytes,
                mime_type=content_type or "image/png"
            )
        else:
            # Extract plain text from doc and parse with Gemini
            raw_text = ocr_service.extract_text_from_file(file_bytes, filename)
            logger.info("Processing FIR text content...")
            extracted_info = gemini_service.extract_fir_details(fir_text=raw_text)
            
        return extracted_info
    except Exception as e:
        logger.error(f"Error processing FIR: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to process FIR document: {str(e)}")


@app.post("/api/v1/detect-contradictions")
def detect_contradictions(request: ContradictionRequest):
    """
    Analyze two witness/suspect statements and spot factual discrepancies.
    """
    try:
        result = gemini_service.detect_contradictions(
            statement_a=request.statement_a,
            statement_b=request.statement_b
        )
        return result
    except Exception as e:
        logger.error(f"Error checking contradictions: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/voice-to-fir")
async def voice_to_fir(file: UploadFile = File(...)):
    """
    Transcribe raw police/witness recordings and draft a structured case FIR summary.
    """
    try:
        audio_bytes = await file.read()
        mime_type = file.content_type or "audio/wav"
        
        # 1. Transcribe audio
        transcript = audio_service.transcribe_audio(audio_bytes, mime_type)
        
        # 2. Structure details via Gemini
        formatted_fir = gemini_service.extract_fir_details(fir_text=transcript)
        
        return {
            "transcript": transcript,
            "formatted_fir": formatted_fir
        }
    except Exception as e:
        logger.error(f"Error processing voice complaint: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/generate-timeline")
def generate_timeline(request: TimelineRequest):
    """
    Construct an interactive chronological events timeline from case documents.
    """
    try:
        return gemini_service.generate_timeline(request.case_text)
    except Exception as e:
        logger.error(f"Error creating timeline: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/generate-link-map")
def generate_link_map(request: LinkMapRequest):
    """
    Create a nodes & edges JSON response to build the Evidence Link Map graph.
    """
    try:
        return gemini_service.generate_evidence_link_map(request.case_details)
    except Exception as e:
        logger.error(f"Error creating link map: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/generate-suggestions")
def generate_suggestions(request: SuggestionsRequest):
    """
    Generate next steps checklist based on case analysis.
    """
    try:
        return gemini_service.generate_ai_suggestions(
            case_summary=request.case_summary,
            missing_info=request.missing_info
        )
    except Exception as e:
        logger.error(f"Error generating suggestions: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/api/v1/reconstruct-crime")
def reconstruct_crime(request: ReconstructionRequest):
    """
    Generate spatial-temporal coordinates to mock a 3D crime reconstruction mapping.
    """
    try:
        return gemini_service.generate_crime_reconstruction(
            statements=request.statements,
            cctv_metadata=request.cctv_metadata
        )
    except Exception as e:
        logger.error(f"Error reconstructing crime: {e}")
        raise HTTPException(status_code=500, detail=str(e))

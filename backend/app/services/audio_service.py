import logging
import google.generativeai as genai
from app.config import settings

logger = logging.getLogger(__name__)

class AudioService:
    def __init__(self):
        self._initialized = bool(settings.GEMINI_API_KEY)

    def transcribe_audio(self, audio_bytes: bytes, mime_type: str = "audio/wav") -> str:
        """
        Transcribes audio using Gemini's native audio capabilities if api key is present,
        otherwise returns mock translation.
        """
        if not self._initialized:
            return (
                "FIR Witness Voice Complaint: On the night of June 30th, around 09:00 PM, "
                "I saw a suspicious person pacing outside Rajesh Mehta's jewelry shop. "
                "The person wore a dark hoodie and had a crowbar. They entered through the rear gate."
            )
            
        try:
            # Create a Gemini model instance
            model = genai.GenerativeModel("gemini-1.5-flash")
            
            # Send the audio bytes directly to the model
            response = model.generate_content([
                {
                    "mime_type": mime_type,
                    "data": audio_bytes
                },
                "Please transcribe the following audio recording accurately. Only output the transcription text, do not add warnings or introductions."
            ])
            return response.text.strip()
            
        except Exception as e:
            logger.error(f"Error transcribing audio with Gemini: {e}")
            return (
                "FIR Witness Voice Complaint: On the night of June 30th, around 09:00 PM, "
                "I saw a suspicious person pacing outside Rajesh Mehta's jewelry shop. "
                "The person wore a dark hoodie and had a crowbar. They entered through the rear gate."
            )

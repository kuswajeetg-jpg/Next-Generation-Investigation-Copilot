# PoliceMind AI – Next Generation Investigation Copilot

> **Tagline**: "One Case. One AI. Complete Investigation Support."

PoliceMind AI is an AI-powered decision support assistant for law enforcement officers and forensic investigators. Instead of functioning as a simple record repository, PoliceMind AI extracts intelligence from reports, transcribes voice statements, uncovers alibi contradictions, charts chronological case timelines, and draws interactive evidence link maps to expedite investigations.

---

## 🚀 Key Features

* **AI FIR Reader**: Upload FIR PDFs or images to extract structured crime metadata, suspects, victims, severity, and gaps in details.
* **Voice-to-FIR**: Directly transcribe audio logs or dictations into standard FIR layouts.
* **Contradiction Detector**: Cross-examine witness accounts to spot timeline, color, or location conflicts.
* **Smart chronological Timeline**: Chronologically chart events from multiple testimonies.
* **Evidence Link Map**: Custom-painted network graph mapping relationships between victims, phones, CCTVs, suspects, and vehicles (App USP).
* **3D Scene Reconstruction Simulation**: Generates coordinates and maps forensic entry/exit paths.
* **Hotspot prediction Maps**: Displays risk alerts on geographical maps.

---

## 🛠️ Technology Stack

* **Frontend**: Flutter (Mobile App UI, custom painter canvas layouts)
* **Backend**: Python FastAPI (Stateless REST processing engine)
* **AI Engine**: Google Gemini API (Multimodal & NLP processing), Whisper API (for audio transcription)
* **Database & Sync**: Firebase (Firestore, Authentication, and Cloud Storage)

---

## 📂 Project Structure

```text
Next Generation Investigation Copilot/
├── backend/                  # FastAPI Application
│   ├── app/
│   │   ├── services/         # Gemini, Audio, and OCR processing services
│   │   ├── main.py           # API endpoint routers
│   │   └── config.py         # Environment configurations
│   ├── tests/                # Pytest verification suites
│   ├── Dockerfile            # Container deployment spec
│   └── requirements.txt      # Python dependencies
├── frontend/                 # Flutter Application
│   ├── lib/
│   │   ├── models/           # Data parsing models
│   │   ├── services/         # API connection class
│   │   ├── screens/          # Login, Dashboard, Uploads, Maps, Reports
│   │   ├── theme.dart        # Sleek dark-mode design system
│   │   └── main.dart         # Flutter startup initialization
│   └── pubspec.yaml          # Flutter package definitions
└── run_project.bat           # Unified double-click launcher script
```

---

## ⚡ Getting Started

### 1. Configure Keys
1. Create a `.env` file inside the `backend/` directory:
   ```env
   GEMINI_API_KEY="your_actual_gemini_api_key_here"
   ```
   *(Note: If no API key is specified, the server automatically defaults to high-quality mockup responses, ensuring you can run offline demos flawlessly for presentations).*

### 2. Fast Launch (Windows)
Double-click the **[run_project.bat](file:///d:/Abul%20Hasan/Next%20Generation%20Investigation%20Copilot/run_project.bat)** file in the root workspace folder. This automatically:
* Fires up the Python FastAPI server in a new window.
* Installs Flutter packages.
* Compiles and launches the mobile application UI on your connected device/emulator.

### 3. Manual Steps
If running manually, refer to the detailed commands guide inside the **[walkthrough.md](file:///C:/Users/Kuswajeet/.gemini/antigravity/brain/de34ec7b-53e1-4997-bce9-f2b36ef37238/walkthrough.md)**.

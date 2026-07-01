# PoliceMind AI: Architecture & System Design

This document details the software architecture, database design, API definitions, and backend-frontend integration specifications for **PoliceMind AI**.

---

## 🏛️ System Architecture

PoliceMind AI is split into three main divisions:
1. **Frontend**: Cross-platform mobile app built with Flutter.
2. **Backend**: Lightweight REST API built with FastAPI (Python) for processing media and interfacing with the Gemini API.
3. **Database & Cloud Storage**: Firebase (Firestore & Cloud Storage) for user sessions, metadata, media, and case file sync.

---

## 🗄️ Database Design (Firestore Collections)

Since Firestore is a NoSQL document database, we organize the data into flat collections with logical subcollections or reference IDs.

```
/users (Police Officers)
  ├── uid: String (Primary Key)
  ├── email: String
  ├── name: String
  ├── badgeNumber: String
  ├── rank: String
  └── createdAt: Timestamp

/cases (Investigations)
  ├── caseId: String (Primary Key)
  ├── caseNumber: String (e.g., "FIR-2026-0891")
  ├── officerId: String (Refers to users.uid)
  ├── title: String
  ├── description: String
  ├── status: String ("Active", "Pending", "Resolved")
  ├── severityScore: Int (1 - 100)
  ├── crimeCategory: String
  ├── dateCreated: Timestamp
  ├── dateModified: Timestamp
  ├── suspects: Array of Objects
  │     ├── name: String
  │     ├── status: String ("Suspect", "Detained", "Absconding")
  │     └── details: String
  ├── victims: Array of Objects
  │     ├── name: String
  │     └── status: String ("Deceased", "Injured", "Safe")
  ├── missingInformation: Array of Strings
  └── timeline: Subcollection of chronological events
  └── evidence: Subcollection of evidence files
```

### `/cases/{caseId}/timeline` (Chronological Timeline Items)
- `eventId`: String (Primary Key)
- `timestamp`: Timestamp
- `title`: String (e.g., "Victim Left Home")
- `description`: String
- `source`: String (e.g., "Witness Statement", "CCTV Log", "FIR")
- `severity`: String ("High", "Medium", "Low")

### `/cases/{caseId}/evidence` (Evidence Catalog)
- `evidenceId`: String (Primary Key)
- `type`: String ("Image", "Video", "Audio", "Document")
- `fileName`: String
- `storageUrl`: String (URL in Firebase Storage)
- `description`: String
- `aiSummary`: String
- `dateUploaded`: Timestamp

---

## 🔌 API Endpoints (FastAPI Backend)

The backend provides stateless endpoints that read uploaded files, trigger Gemini processing, and return structured JSON.

### 1. Document Extraction & OCR
* **Endpoint**: `POST /api/v1/extract-fir`
* **Request**: Multipart Form Data (`file`: PDF or Image)
* **Response**:
  ```json
  {
    "case_number": "FIR-2026-102A",
    "crime_category": "Burglary",
    "severity_score": 45,
    "suspects": [
      { "name": "Rahul Verma", "details": "Seen running near the rear entrance" }
    ],
    "victims": [
      { "name": "Sanjay Sharma", "status": "Unharmed" }
    ],
    "incident_summary": "On the night of June 30th...",
    "missing_information": [
      "Exact entry point timeline",
      "List of stolen items value"
    ]
  }
  ```

### 2. Contradiction Detection
* **Endpoint**: `POST /api/v1/detect-contradictions`
* **Request**: JSON
  ```json
  {
    "statement_a": {
      "witness": "Officer Dave",
      "content": "I saw a black SUV parked outside the jeweler at 9:15 PM. The license plate ended with 4321."
    },
    "statement_b": {
      "witness": "Suspect John",
      "content": "I was at a local diner from 8:45 PM to 9:30 PM. I drive a silver sedan and my license plate ends with 8812."
    }
  }
  ```
* **Response**:
  ```json
  {
    "contradictions_found": true,
    "discrepancies": [
      {
        "topic": "Vehicle Type and Color",
        "description": "Statement A reports a black SUV, while Statement B claims a silver sedan.",
        "severity": "High"
      },
      {
        "topic": "Time & Alibi Verification",
        "description": "Cross-verification needed with CCTV of the diner between 8:45 PM and 9:30 PM to confirm Suspect John's location.",
        "severity": "Medium"
      }
    ]
  }
  ```

### 3. Voice to FIR Draft
* **Endpoint**: `POST /api/v1/voice-to-fir`
* **Request**: Multipart Form Data (`audio`: WAV/MP3 file)
* **Response**:
  ```json
  {
    "transcript": "Uhh, so we arrived at the scene around 9 PM... victim was already gone...",
    "formatted_fir": {
      "incident_description": "First responder arrived at the crime scene at approximately 21:00 hours. The victim was reported missing prior to arrival.",
      "proposed_title": "Missing Person Incident",
      "suggested_actions": ["Search victim cell records", "Check CCTV coverage at 20:30-21:00"]
    }
  }
  ```

---

## 🤖 Gemini API Prompt Engineering Guidelines

To guarantee high-quality structured output, the FastAPI backend uses **System Instructions** and **Structured JSON Schema** outputs with Gemini.

### Prompt: FIR Parsing System Instruction
```
You are an expert police inspector and legal AI assistant. Your goal is to read raw OCR texts or images of FIR reports and extract standard metadata in clean JSON format.
Ensure you assign a "severity_score" from 1 to 100 based on the presence of weapons, physical harm, and legal codes cited.
```

### Prompt: Contradiction Detection
```
Compare the two statements provided. Identify any direct conflicts in timeline, location, actions, descriptions of individuals, or vehicle license plates. Output the conflicts in a structured format containing a severity level (High/Medium/Low) and a recommendation on how the investigator can verify which statement is true.
```

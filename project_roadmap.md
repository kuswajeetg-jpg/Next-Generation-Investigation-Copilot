# PoliceMind AI: Project Roadmap & Timeline

This document maps out the phases, milestones, and development checklist for **PoliceMind AI** to go from concept to a winning hackathon prototype.

---

## 📅 Roadmap Overview

```
Phases:
┌──────────────────────────┐     ┌──────────────────────────┐     ┌──────────────────────────┐
│   Phase 1: Foundation    │ ──> │    Phase 2: AI Core      │ ──> │   Phase 3: Visual & UX   │
│  Setup Project Scaffold  │     │   OCR, Gemini, Whisper   │     │  Link Map, Timeline UI   │
└──────────────────────────┘     └──────────────────────────┘     └──────────────────────────┘
```

---

## 📌 Milestones and Action Items

### Phase 1: Environment & Scaffolding (Target: Day 1-2)
- [ ] **Flutter Setup**
  - Initialize Flutter project with standard folder layout (features, models, services, screens, widgets).
  - Configure dependencies in `pubspec.yaml` (Firebase SDK, Riverpod/Provider, HTTP client, Google Fonts).
  - Setup sleek dark theme parameters.
- [ ] **Backend Setup**
  - Scaffold FastAPI project with route controllers and core configuration.
  - Setup virtual environment, dependencies (`fastapi`, `uvicorn`, `google-generativeai`, `pydantic`).
- [ ] **Firebase Scaffolding**
  - Setup Firestore DB collections outline.
  - Setup Cloud Storage folders for media (images, audio, PDF uploads).

### Phase 2: Core AI Engines (Target: Day 2-3)
- [ ] **AI FIR Reader Endpoint**
  - Implement PDF upload endpoint.
  - Connect text parsing + Gemini structured extraction.
- [ ] **Voice to FIR Engine**
  - Implement audio file processor endpoint.
  - Integrate Whisper model transcription with Gemini text summarizer.
- [ ] **Contradiction Detector Router**
  - Define schema validation for witness statements.
  - Build Gemini comparative prompt helper.
- [ ] **Smart Suggestions Engine**
  - Implement rules-based and AI-suggested investigator actions.

### Phase 3: High-Fidelity App Views (Target: Day 3-4)
- [ ] **8-Screen Frontend Implementation**
  - Screen 1: **Biometric Login** (Mock face detector visual & passcode lock).
  - Screen 2: **Dashboard** (Interactive map placeholder, list of active cases, hot actions).
  - Screen 3: **New Case File Room** (Media picker buttons, upload status indicators).
  - Screen 4: **AI Analysis Summary** (Confidence scoring meters, cards displaying extracted suspect information).
  - Screen 5: **Timeline Viewer** (Custom timeline widgets showing steps of incident).
  - Screen 6: **Evidence Link Map UI** (Canvas graph showing nodes & relations: Suspect ➔ Car ➔ CCTV).
  - Screen 7: **AI Action Suggestions** (Interactive checklist with completion switches).
  - Screen 8: **AI Report View** (Export to PDF, share, download widgets).

### Phase 4: Integration, Testing & Hackathon Polish (Target: Day 4-5)
- [ ] **Flutter-FastAPI Integration**
  - Connect UI upload buttons to the actual REST endpoints.
  - Integrate visual loading feedback (micro-animations, shimmer loading bars) for AI operations.
- [ ] **3D Scene Reconstruction Simulation**
  - Build interactive mockup of entry/exit point visualizations or layout sketch inside the app as a "future features sneak peek".
- [ ] **Hackathon Pitch Demo Prep**
  - Verify speed of case updates.
  - Setup a mock "Express Demo Mode" that instantly populates the case with a predefined FIR and sample evidence files to guarantee zero latency during judges' presentations.

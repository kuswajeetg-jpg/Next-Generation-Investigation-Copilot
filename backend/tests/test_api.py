import sys
import os
# Add 'app' directory to python path
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_read_root():
    response = client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["status"] == "online"
    assert "version" in data

def test_detect_contradictions():
    response = client.post(
        "/api/v1/detect-contradictions",
        json={
            "statement_a": {"witness": "Rajesh", "content": "I saw a black SUV getaway car"},
            "statement_b": {"witness": "Vikram", "content": "I drive a silver sedan"}
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert "contradictions_found" in data
    assert len(data["discrepancies"]) > 0

def test_generate_timeline():
    response = client.post(
        "/api/v1/generate-timeline",
        json={"case_text": "Incident details of Mehta burglary"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "timeline" in data
    assert len(data["timeline"]) > 0

def test_generate_link_map():
    response = client.post(
        "/api/v1/generate-link-map",
        json={"case_details": "Victim has phone. CCTV recorded vehicle."}
    )
    assert response.status_code == 200
    data = response.json()
    assert "nodes" in data
    assert "edges" in data
    assert len(data["nodes"]) > 0

def test_generate_suggestions():
    response = client.post(
        "/api/v1/generate-suggestions",
        json={
            "case_summary": "Mehta jewellers robbery details",
            "missing_info": ["CCTV footage link"]
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert "suggestions" in data
    assert len(data["suggestions"]) > 0

def test_reconstruct_crime():
    response = client.post(
        "/api/v1/reconstruct-crime",
        json={
            "statements": ["Witness statements list"],
            "cctv_metadata": ["CCTV camera metadata list"]
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert "event_flow" in data
    assert "entry_points" in data
    assert "reconstruction_summary" in data

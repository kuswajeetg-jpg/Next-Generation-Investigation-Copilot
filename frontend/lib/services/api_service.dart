import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/case_model.dart';

class ApiService {
  // Use http://10.0.2.2:8000 for Android Emulator, http://localhost:8000 for iOS simulator / web / desktop
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return "http://10.0.2.2:8000";
    }
    return "http://localhost:8000";
  }

  // Upload FIR PDF or Image and return case structure
  Future<CaseModel> uploadAndExtractFir(Uint8List fileBytes, String filename) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/extract-fir'),
      );
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: filename,
        ),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = json.decode(responseBody);
        return CaseModel.fromJson(data);
      } else {
        throw Exception("Failed to parse FIR: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error in uploadAndExtractFir: $e");
      rethrow;
    }
  }

  // Upload Audio recording for Voice-to-FIR
  Future<Map<String, dynamic>> voiceToFir(Uint8List audioBytes, String filename) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/v1/voice-to-fir'),
      );
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          audioBytes,
          filename: filename,
        ),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return json.decode(responseBody);
      } else {
        throw Exception("Failed to transcribe voice complaint: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error in voiceToFir: $e");
      rethrow;
    }
  }

  // Fetch Timeline Events
  Future<List<TimelineEvent>> getTimeline(String caseText) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/generate-timeline'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'case_text': caseText}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List list = data['timeline'] ?? [];
        return list.map((e) => TimelineEvent.fromJson(e)).toList();
      } else {
        throw Exception("Failed to generate timeline");
      }
    } catch (e) {
      debugPrint("Error in getTimeline: $e");
      return [];
    }
  }

  // Fetch Evidence Link Map graph
  Future<Map<String, dynamic>> getEvidenceLinkMap(String caseDetails) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/generate-link-map'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'case_details': caseDetails}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List nodesList = data['nodes'] ?? [];
        final List edgesList = data['edges'] ?? [];
        
        return {
          'nodes': nodesList.map((e) => LinkMapNode.fromJson(e)).toList(),
          'edges': edgesList.map((e) => LinkMapEdge.fromJson(e)).toList(),
        };
      } else {
        throw Exception("Failed to generate link map");
      }
    } catch (e) {
      debugPrint("Error in getEvidenceLinkMap: $e");
      return {'nodes': <LinkMapNode>[], 'edges': <LinkMapEdge>[]};
    }
  }

  // Fetch AI Action suggestions
  Future<List<InvestigationSuggestion>> getSuggestions(String caseSummary, List<String> missingInfo) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/generate-suggestions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'case_summary': caseSummary,
          'missing_info': missingInfo,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List list = data['suggestions'] ?? [];
        return list.map((e) => InvestigationSuggestion.fromJson(e)).toList();
      } else {
        throw Exception("Failed to generate suggestions");
      }
    } catch (e) {
      debugPrint("Error in getSuggestions: $e");
      return [];
    }
  }

  // Check Contradictions between two statements
  Future<Map<String, dynamic>> checkContradictions(Map<String, dynamic> stmtA, Map<String, dynamic> stmtB) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/detect-contradictions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'statement_a': stmtA,
          'statement_b': stmtB,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to execute contradiction checker");
      }
    } catch (e) {
      debugPrint("Error in checkContradictions: $e");
      rethrow;
    }
  }

  // AI 3D Reconstruction Simulation JSON provider
  Future<Map<String, dynamic>> reconstructCrime(List<String> statements, List<String> cctvs) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/v1/reconstruct-crime'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'statements': statements,
          'cctv_metadata': cctvs,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception("Failed to reconstruct crime");
      }
    } catch (e) {
      debugPrint("Error in reconstructCrime: $e");
      rethrow;
    }
  }
}

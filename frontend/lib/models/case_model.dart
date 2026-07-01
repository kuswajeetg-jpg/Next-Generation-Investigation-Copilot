import 'dart:convert';

class CaseModel {
  final String id;
  final String caseNumber;
  final String title;
  final String description;
  final String status;
  final String category;
  final int severityScore;
  final List<Suspect> suspects;
  final List<Victim> victims;
  final List<String> missingInfo;
  final List<TimelineEvent> timeline;

  CaseModel({
    required this.id,
    required this.caseNumber,
    required this.title,
    required this.description,
    required this.status,
    required this.category,
    required this.severityScore,
    required this.suspects,
    required this.victims,
    required this.missingInfo,
    required this.timeline,
  });

  factory CaseModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return CaseModel(
      id: id ?? json['id'] ?? 'mock_id',
      caseNumber: json['case_number'] ?? 'FIR-NEW',
      title: json['title'] ?? 'New Investigation',
      description: json['incident_summary'] ?? json['description'] ?? '',
      status: json['status'] ?? 'Active',
      category: json['crime_category'] ?? 'General',
      severityScore: json['severity_score'] ?? 50,
      suspects: (json['suspects'] as List?)?.map((x) => Suspect.fromJson(x)).toList() ?? [],
      victims: (json['victims'] as List?)?.map((x) => Victim.fromJson(x)).toList() ?? [],
      missingInfo: List<String>.from(json['missing_information'] ?? []),
      timeline: (json['timeline'] as List?)?.map((x) => TimelineEvent.fromJson(x)).toList() ?? [],
    );
  }
}

class Suspect {
  final String name;
  final String details;

  Suspect({required this.name, required this.details});

  factory Suspect.fromJson(Map<String, dynamic> json) {
    return Suspect(
      name: json['name'] ?? 'Unknown Suspect',
      details: json['details'] ?? '',
    );
  }
}

class Victim {
  final String name;
  final String status;

  Victim({required this.name, required this.status});

  factory Victim.fromJson(Map<String, dynamic> json) {
    return Victim(
      name: json['name'] ?? 'Unknown Victim',
      status: json['status'] ?? 'Unknown',
    );
  }
}

class TimelineEvent {
  final String time;
  final String title;
  final String description;
  final String source;

  TimelineEvent({
    required this.time,
    required this.title,
    required this.description,
    required this.source,
  });

  factory TimelineEvent.fromJson(Map<String, dynamic> json) {
    return TimelineEvent(
      time: json['time'] ?? '00:00',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      source: json['source'] ?? 'General',
    );
  }
}

class LinkMapNode {
  final String id;
  final String label;
  final String type; // victim, suspect, phone, vehicle, cctv, location

  LinkMapNode({required this.id, required this.label, required this.type});

  factory LinkMapNode.fromJson(Map<String, dynamic> json) {
    return LinkMapNode(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? 'general',
    );
  }
}

class LinkMapEdge {
  final String from;
  final String to;
  final String relation;

  LinkMapEdge({required this.from, required this.to, required this.relation});

  factory LinkMapEdge.fromJson(Map<String, dynamic> json) {
    return LinkMapEdge(
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      relation: json['relation'] ?? '',
    );
  }
}

class InvestigationSuggestion {
  final String task;
  final String priority;
  final String reason;

  InvestigationSuggestion({required this.task, required this.priority, required this.reason});

  factory InvestigationSuggestion.fromJson(Map<String, dynamic> json) {
    return InvestigationSuggestion(
      task: json['task'] ?? '',
      priority: json['priority'] ?? 'Medium',
      reason: json['reason'] ?? '',
    );
  }
}

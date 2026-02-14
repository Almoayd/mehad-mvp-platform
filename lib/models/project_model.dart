import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectModel {
  final String id;
  final String clientId;
  final String type;
  final String location;
  final double minBudget;
  final double maxBudget;
  final String description;
  final String status; // Pending, Active, Done
  final Timestamp createdAt;

  ProjectModel({
    required this.id,
    required this.clientId,
    required this.type,
    required this.location,
    required this.minBudget,
    required this.maxBudget,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map, String id) {
    return ProjectModel(
      id: id,
      clientId: map['clientId'] ?? '',
      type: map['type'] ?? '',
      location: map['location'] ?? '',
      minBudget: (map['minBudget'] ?? 0).toDouble(),
      maxBudget: (map['maxBudget'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      status: map['status'] ?? 'Pending',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clientId': clientId,
      'type': type,
      'location': location,
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'description': description,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

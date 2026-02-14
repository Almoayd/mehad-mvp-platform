import 'package:cloud_firestore/cloud_firestore.dart';

class OfferModel {
  final String id;
  final String projectId;
  final String contractorId;
  final double price;
  final String message;
  final String status; // Submitted, Accepted, Rejected
  final Timestamp createdAt;

  OfferModel({
    required this.id,
    required this.projectId,
    required this.contractorId,
    required this.price,
    required this.message,
    required this.status,
    required this.createdAt,
  });

  factory OfferModel.fromMap(Map<String, dynamic> map, String id) {
    return OfferModel(
      id: id,
      projectId: map['projectId'] ?? '',
      contractorId: map['contractorId'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      message: map['message'] ?? '',
      status: map['status'] ?? 'Submitted',
      createdAt: map['createdAt'] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'contractorId': contractorId,
      'price': price,
      'message': message,
      'status': status,
      'createdAt': createdAt,
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class KitchenModel {
  final String id;
  final String hotelId;
  final String name;
  final String status;
  final List<String> storages;
  final Timestamp createdAt;

  KitchenModel({
    required this.id,
    required this.hotelId,
    required this.name,
    required this.status,
    required this.storages,
    required this.createdAt,
  });

  factory KitchenModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KitchenModel(
      id: doc.id,
      hotelId: data['hotelId'],
      name: data['name'],
      status: data['status'],
      storages: List<String>.from(data['storages'] ?? []),
      createdAt: data['createdAt'],
    );
  }
}

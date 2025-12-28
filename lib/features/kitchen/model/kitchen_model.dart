import 'package:cloud_firestore/cloud_firestore.dart';

class KitchenModel {
  final String id;
  final String hotelId;
  final String hotelName;
  final String name;
  final String status;
  final List<String> storages;
  final Timestamp createdAt;

  KitchenModel({
    required this.id,
    required this.hotelId,
    required this.hotelName,
    required this.name,
    required this.status,
    required this.storages,
    required this.createdAt,
  });

  factory KitchenModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return KitchenModel(
      id: doc.id,
      hotelId: data['hotelId'] ?? '',
      hotelName: data['hotelName'] ?? '',
      name: data['name'] ?? '',
      status: data['status'] ?? 'Active',
      storages: List<String>.from(data['storages'] ?? []),
      createdAt: data['createdAt'] ?? Timestamp.now(),
    );
  }

  KitchenModel copyWith({
    String? id,
    String? hotelId,
    String? hotelName,
    String? name,
    String? status,
    List<String>? storages,
    Timestamp? createdAt,
  }) {
    return KitchenModel(
      id: id ?? this.id,
      hotelId: hotelId ?? this.hotelId,
      hotelName: hotelName ?? this.hotelName,
      name: name ?? this.name,
      status: status ?? this.status,
      storages: storages ?? this.storages,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

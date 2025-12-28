import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String hotelId;
  final String hotelName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.hotelId = '',
    this.hotelName = '',
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromDoc(String id, Map<String, dynamic> doc) {
    return CategoryModel(
      id: id,
      name: doc['name'] ?? '',
      description: doc['description'] ?? '',
      hotelId: doc['hotelId'] ?? '',
      hotelName: doc['hotelName'] ?? '',
      createdAt: (doc['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (doc['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

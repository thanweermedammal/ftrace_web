import 'package:cloud_firestore/cloud_firestore.dart';

class SupplierModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String hotelId;
  final String hotelName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SupplierModel({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.address = '',
    this.hotelId = '',
    this.hotelName = '',
    this.createdAt,
    this.updatedAt,
  });

  factory SupplierModel.fromDoc(String id, Map<String, dynamic> doc) {
    return SupplierModel(
      id: id,
      name: doc['name'] ?? '',
      email: doc['email'] ?? '',
      phone: doc['phone'] ?? '',
      address: doc['address'] ?? '',
      hotelId: doc['hotelId'] ?? '',
      hotelName: doc['hotelName'] ?? '',
      createdAt: (doc['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (doc['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

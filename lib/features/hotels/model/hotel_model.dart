import 'package:cloud_firestore/cloud_firestore.dart';

class HotelModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String status;
  final List<String> kitchens;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  HotelModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.status,
    required this.kitchens,
    this.createdAt,
    this.updatedAt,
  });

  factory HotelModel.fromFirestore(doc, {List<String>? kitchens}) {
    final data = doc.data();
    return HotelModel(
      id: data['id'] ?? doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      status: data['status'] ?? 'ACTIVE',
      kitchens:
          kitchens ??
          (data['kitchens'] != null ? List<String>.from(data['kitchens']) : []),
      createdAt: data['createdAt'],
      updatedAt: data['updatedAt'],
    );
  }

  HotelModel copyWith({
    List<String>? kitchens,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? status,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return HotelModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      status: status ?? this.status,
      kitchens: kitchens ?? this.kitchens,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

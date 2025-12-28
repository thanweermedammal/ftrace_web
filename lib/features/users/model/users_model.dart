// user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String status;
  final List<String> hotelIds;
  final List<String> hotelNames;
  final List<String> kitchenIds;
  final String address;
  final String password;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.status,
    required this.hotelIds,
    required this.hotelNames,
    required this.kitchenIds,
    this.address = '',
    this.password = '',
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    return UserModel(
      id: id,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
      status: json['status'] ?? 'Active',
      hotelIds: List<String>.from(json['hotelIds'] ?? []),
      hotelNames: List<String>.from(json['hotelNames'] ?? []),
      kitchenIds: List<String>.from(json['kitchenIds'] ?? []),
      address: json['address'] ?? '',
      password: json['password'] ?? '',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as dynamic).toDate()
          : null,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as dynamic).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'status': status,
      'hotelIds': hotelIds,
      'hotelNames': hotelNames,
      'kitchenIds': kitchenIds,
      'address': address,
      'password': password,
      'updatedAt': DateTime.now(),
      if (createdAt == null)
        'createdAt': DateTime.now()
      else
        'createdAt': createdAt,
    };
  }
}

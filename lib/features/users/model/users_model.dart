// user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String status;
  final List<String> hotelIds;
  final List<String> kitchenIds;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.status,
    required this.hotelIds,
    required this.kitchenIds,
  });

  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    return UserModel(
      id: id,
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'] ?? '',
      status: json['status'],
      hotelIds: List<String>.from(json['hotelIds'] ?? []),
      kitchenIds: List<String>.from(json['kitchenIds'] ?? []),
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
      'kitchenIds': kitchenIds,
      'createdAt': DateTime.now(),
    };
  }
}

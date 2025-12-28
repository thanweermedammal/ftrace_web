class HotelModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String status;

  HotelModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
  });

  factory HotelModel.fromFirestore(doc) {
    final data = doc.data();
    return HotelModel(
      id: data['id'],
      name: data['name'],
      email: data['email'],
      phone: data['phone'],
      status: data['status'],
    );
  }
}

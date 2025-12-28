import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/hotel_model.dart';

class HotelRepository {
  final _db = FirebaseFirestore.instance;

  // 🔹 Get all hotels
  Stream<List<HotelModel>> getHotels() {
    return _db.collection('hotels').snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => HotelModel.fromFirestore(doc))
          .toList(),
    );
  }

  // 🔹 Get kitchen count per hotel
  Future<int> getKitchenCount(String hotelId) async {
    final snapshot = await _db
        .collection('hotels')
        .doc(hotelId)
        .collection('kitchens')
        .get();

    return snapshot.docs.length;
  }

  // 🔹 Add hotel
  Future<void> addHotel({
    required String id,
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    await _db.collection('hotels').doc(id).set({
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'status': 'ACTIVE',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

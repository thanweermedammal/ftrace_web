import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ftrace_web/features/hotels/model/hotel_model.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';

class HotelRepository {
  final _db = FirebaseFirestore.instance;

  // 🔹 Get all hotels with kitchens
  Stream<List<HotelModel>> getHotels({UserModel? currentUser}) {
    Query query = _db.collection('hotels');

    // 🔹 Apply Role-Based Filtering
    if (currentUser != null && currentUser.role.toLowerCase() != 'superadmin') {
      if (currentUser.hotelIds.isNotEmpty) {
        query = query.where(
          FieldPath.documentId,
          whereIn: currentUser.hotelIds,
        );
      } else {
        // No hotel assigned, return empty list
        return Stream.value([]);
      }
    }

    return query.snapshots().asyncMap((snapshot) async {
      List<HotelModel> hotels = [];

      for (var doc in snapshot.docs) {
        // Fetch kitchens subcollection
        final kitchenSnapshot = await doc.reference
            .collection('kitchens')
            .get();
        final kitchenNames = kitchenSnapshot.docs
            .map((k) => k.data()['name'] as String? ?? 'Unknown')
            .toList();

        hotels.add(HotelModel.fromFirestore(doc, kitchens: kitchenNames));
      }

      return hotels;
    });
  }

  // 🔹 Get kitchen count per hotel
  Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> getKitchens(
    String hotelId,
  ) async {
    final snapshot = await _db
        .collection('hotels')
        .doc(hotelId)
        .collection('kitchens')
        .get();

    return snapshot.docs;
  }

  // 🔹 Add a new hotel
  Future<String> addHotel(HotelModel hotel) async {
    final docRef = await _db.collection('hotels').add({
      'name': hotel.name,
      'email': hotel.email,
      'phone': hotel.phone,
      'address': hotel.address,
      'status': hotel.status,
      'kitchens': hotel.kitchens,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update the document with its own ID
    await docRef.update({'id': docRef.id});

    return docRef.id;
  }

  // 🔹 Update existing hotel
  Future<void> updateHotel(HotelModel hotel) async {
    await _db.collection('hotels').doc(hotel.id).update({
      'name': hotel.name,
      'email': hotel.email,
      'phone': hotel.phone,
      'address': hotel.address,
      'status': hotel.status,
      // 'kitchens': hotel.kitchens, // Kitchens might be managed separately or via this. Keeping it in sync.
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 🔹 Add kitchen to hotel
  Future<void> addKitchen(String hotelId, String name) async {
    await _db.collection('hotels').doc(hotelId).collection('kitchens').add({
      'name': name,
      'status': 'ACTIVE',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Touch the parent hotel to trigger the stream listener
    await _db.collection('hotels').doc(hotelId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // // 🔹 Delete multiple hotels
  // Future<void> deleteHotels(List<String> hotelIds) async {
  //   final batch = _db.batch();
  //   for (final id in hotelIds) {
  //     batch.delete(_db.collection('hotels').doc(id));
  //   }
  //   await batch.commit();
  // }
  Future<void> deleteHotels(List<String> hotelIds) async {
    for (final hotelId in hotelIds) {
      final hotelRef = _db.collection('hotels').doc(hotelId);

      final subCollections = [
        'products',
        'suppliers',
        'dishes',
        'kitchens',
        'categories',
        'operations'
      ];

      for (final col in subCollections) {
        final snap = await hotelRef.collection(col).get();
        for (final doc in snap.docs) {
          await doc.reference.delete();
        }
      }

      await hotelRef.delete();
    }
  }

}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ftrace_web/features/kitchen/model/kitchen_model.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';

class KitchenRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// FETCH KITCHENS OF A HOTEL OR ALL ASSIGNED
  Stream<List<KitchenModel>> fetchKitchens({
    String? hotelId,
    String? status,
    UserModel? currentUser,
  }) {
    Query query = _firestore.collectionGroup('kitchens');

    // 🔹 Apply Role-Based Filtering
    if (currentUser != null && currentUser.role.toLowerCase() != 'superadmin') {
      if (currentUser.hotelIds.isNotEmpty) {
        query = query.where('hotelId', whereIn: currentUser.hotelIds);
      } else if (currentUser.kitchenIds.isNotEmpty) {
        query = query.where(
          FieldPath.documentId,
          whereIn: currentUser.kitchenIds,
        );
      } else {
        return Stream.value([]);
      }
    }

    // Optional: Filter by specific hotelId if provided
    if (hotelId != null && hotelId.isNotEmpty) {
      query = query.where('hotelId', isEqualTo: hotelId);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map((e) => KitchenModel.fromDoc(e)).toList(),
    );
  }

  /// ADD KITCHEN (AUTO ID)
  Future<void> addKitchen({
    required String hotelId,
    required String hotelName,
    required String name,
    String status = "ACTIVE",
    List<String> storages = const [],
  }) async {
    final ref = _firestore
        .collection('hotels')
        .doc(hotelId)
        .collection('kitchens')
        .doc(); // auto ID

    await ref.set({
      'id': ref.id,
      'hotelName': hotelName,
      'hotelId': hotelId,
      'name': name,
      'status': status,
      'storages': storages,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Touch the parent hotel to trigger the stream listener
    await _firestore.collection('hotels').doc(hotelId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// UPDATE KITCHEN
  Future<void> updateKitchen({required KitchenModel kitchen}) async {
    await _firestore
        .collection('hotels')
        .doc(kitchen.hotelId)
        .collection('kitchens')
        .doc(kitchen.id)
        .update({
          'name': kitchen.name,
          'hotelName': kitchen.hotelName,
          'hotelId': kitchen.hotelId,
          'status': kitchen.status,
          'storages': kitchen.storages,
          'updatedAt': FieldValue.serverTimestamp(),
        });

    // Touch the parent hotel to trigger the stream listener
    await _firestore.collection('hotels').doc(kitchen.hotelId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// DELETE KITCHEN (OPTIONAL)
  Future<void> deleteKitchen({
    required String hotelId,
    required String kitchenId,
  }) async {
    await _firestore
        .collection('hotels')
        .doc(hotelId)
        .collection('kitchens')
        .doc(kitchenId)
        .delete();

    // Touch the parent hotel to trigger the stream listener
    await _firestore.collection('hotels').doc(hotelId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // 🔹 Delete multiple kitchens across hotels
  Future<void> deleteKitchensAcrossHotels(List<KitchenModel> kitchens) async {
    const batchLimit = 400;

    for (var i = 0; i < kitchens.length; i += batchLimit) {
      final batch = _firestore.batch();

      final chunk = kitchens.skip(i).take(batchLimit);

      for (final k in chunk) {
        batch.delete(
          _firestore
              .collection('hotels')
              .doc(k.hotelId)
              .collection('kitchens')
              .doc(k.id),
        );
      }

      await batch.commit();
    }
  }
}

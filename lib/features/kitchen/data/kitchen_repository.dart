import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/kitchen_model.dart';

class KitchenRepository {
  final _ref = FirebaseFirestore.instance.collection('kitchens');

  /// FETCH
  Stream<List<KitchenModel>> fetchKitchens({
    required String hotelId,
    String? status,
  }) {
    Query query = _ref.where('hotelId', isEqualTo: hotelId);

    if (status != null) {
      query = query.where('status', isEqualTo: status);
    }

    return query.snapshots().map(
          (snapshot) =>
          snapshot.docs.map((e) => KitchenModel.fromDoc(e)).toList(),
    );
  }

  /// ADD (Firebase auto ID)
  Future<void> addKitchen({
    required String hotelId,
    required String name,
    required String status,
    required List<String> storages,
  }) async {
    await _ref.add({
      'hotelId': hotelId,
      'name': name,
      'status': status,
      'storages': storages,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}

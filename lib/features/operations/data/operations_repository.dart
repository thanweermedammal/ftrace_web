import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/operations_model.dart';

class OperationsRepository {
  final _db = FirebaseFirestore.instance;

  // RECEIVING
  Stream<List<ReceivingModel>> fetchReceivingLogs() {
    return _db
        .collection('receiving_logs')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => ReceivingModel.fromDoc(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addReceivingLog(ReceivingModel log) async {
    await _db.collection('receiving_logs').add(log.toJson());
  }

  // KITCHEN STORAGES (Movements)
  Stream<List<KitchenStorageModel>> fetchStorageMovements() {
    return _db
        .collection('storage_movements')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => KitchenStorageModel.fromDoc(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addStorageMovement(KitchenStorageModel movement) async {
    await _db.collection('storage_movements').add(movement.toJson());
  }
  // 🔹 Delete multiple hotels
  Future<void> deleteOperationsAcrossHotels(
      List<ReceivingModel> operations,
      ) async {
    const batchLimit = 400;

    for (var i = 0; i < operations.length; i += batchLimit) {
      final batch = _db.batch();

      final chunk = operations.skip(i).take(batchLimit);

      for (final k in chunk) {
        batch.delete(
          _db
              .collection('hotels')
              .doc(k.hotelId)
              .collection('operations')
              .doc(k.id),
        );
      }

      await batch.commit();
    }
  }
}

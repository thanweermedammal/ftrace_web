import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';
import '../model/supplier_model.dart';

class SuppliersRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<SupplierModel>> fetchSuppliers(
    String? hotelId, {
    String? query,
    UserModel? currentUser,
  }) {
    Query collectionRef;
    if (hotelId != null && hotelId.isNotEmpty) {
      collectionRef = _db
          .collection('hotels')
          .doc(hotelId)
          .collection('suppliers');
    } else {
      collectionRef = _db.collectionGroup('suppliers');
      if (currentUser != null &&
          currentUser.role.toLowerCase() != 'superadmin') {
        if (currentUser.hotelIds.isNotEmpty) {
          collectionRef = collectionRef.where(
            'hotelId',
            whereIn: currentUser.hotelIds,
          );
        } else {
          return Stream.value([]);
        }
      }
    }

    return collectionRef.snapshots().map((snap) {
      final list = snap.docs
          .where((doc) => doc.reference.path.split('/').length == 4)
          .map(
            (doc) => SupplierModel.fromDoc(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();

      // Client-side sorting
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      if (query == null || query.isEmpty) return list;
      final q = query.toLowerCase();
      return list
          .where(
            (s) =>
                s.name.toLowerCase().contains(q) ||
                s.email.toLowerCase().contains(q) ||
                s.phone.toLowerCase().contains(q) ||
                s.address.toLowerCase().contains(q),
          )
          .toList();
    });
  }

  Future<void> addSuppliers(
    List<String> names,
    String hotelId,
    String hotelName,
  ) async {
    final batch = _db.batch();
    for (final name in names) {
      if (name.trim().isEmpty) continue;
      final docRef = _db
          .collection('hotels')
          .doc(hotelId)
          .collection('suppliers')
          .doc();
      batch.set(docRef, {
        'name': name.trim(),
        'email': '',
        'phone': '',
        'address': '',
        'hotelId': hotelId,
        'hotelName': hotelName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> updateSupplier(SupplierModel supplier) async {
    await _db
        .collection('hotels')
        .doc(supplier.hotelId)
        .collection('suppliers')
        .doc(supplier.id)
        .update(supplier.toJson());
  }

  Future<void> deleteSupplier(String hotelId, String id) async {
    await _db
        .collection('hotels')
        .doc(hotelId)
        .collection('suppliers')
        .doc(id)
        .delete();
  }

  Future<void> deleteSuppliers(String hotelId, List<String> ids) async {
    final batch = _db.batch();
    for (final id in ids) {
      batch.delete(
        _db.collection('hotels').doc(hotelId).collection('suppliers').doc(id),
      );
    }
    await batch.commit();
  }
}

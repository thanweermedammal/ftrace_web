import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';
import '../model/category_model.dart';

class CategoriesRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<CategoryModel>> fetchCategories(
    String? hotelId, {
    String? query,
    UserModel? currentUser,
  }) {
    Query collectionRef;
    if (hotelId != null && hotelId.isNotEmpty) {
      collectionRef = _db
          .collection('hotels')
          .doc(hotelId)
          .collection('categories');
    } else {
      collectionRef = _db.collectionGroup('categories');
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
            (doc) => CategoryModel.fromDoc(
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
            (c) =>
                c.name.toLowerCase().contains(q) ||
                c.description.toLowerCase().contains(q),
          )
          .toList();
    });
  }

  Future<void> addCategories(
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
          .collection('categories')
          .doc();
      batch.set(docRef, {
        'name': name.trim(),
        'description': '',
        'hotelId': hotelId,
        'hotelName': hotelName,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }

  Future<void> updateCategory(CategoryModel category) async {
    await _db
        .collection('hotels')
        .doc(category.hotelId)
        .collection('categories')
        .doc(category.id)
        .update(category.toJson());
  }

  Future<void> deleteCategory(String hotelId, String id) async {
    await _db
        .collection('hotels')
        .doc(hotelId)
        .collection('categories')
        .doc(id)
        .delete();
  }

  Future<void> deleteCategories(String hotelId, List<String> ids) async {
    final batch = _db.batch();
    for (final id in ids) {
      batch.delete(
        _db.collection('hotels').doc(hotelId).collection('categories').doc(id),
      );
    }
    await batch.commit();
  }
}

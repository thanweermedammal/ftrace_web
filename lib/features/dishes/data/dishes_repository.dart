import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/dish_model.dart';

class DishesRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<DishModel>> fetchDishes(String? hotelId) {
    Query collectionRef;
    if (hotelId != null && hotelId.isNotEmpty) {
      collectionRef = _db
          .collection('hotels')
          .doc(hotelId)
          .collection('dishes');
    } else {
      collectionRef = _db.collectionGroup('dishes');
    }

    return collectionRef.snapshots().map((snap) {
      final list = snap.docs
          .map(
            (doc) =>
                DishModel.fromDoc(doc.id, doc.data() as Map<String, dynamic>),
          )
          .toList();

      // Client-side sorting
      list.sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate); // descending
      });

      return list;
    });
  }

  Future<void> addDish(DishModel dish) async {
    await _db
        .collection('hotels')
        .doc(dish.hotelId)
        .collection('dishes')
        .add(dish.toJson());
  }

  Future<void> updateDish(DishModel dish) async {
    await _db
        .collection('hotels')
        .doc(dish.hotelId)
        .collection('dishes')
        .doc(dish.id)
        .update(dish.toJson());
  }

  Future<void> deleteDish(String hotelId, String id) async {
    await _db
        .collection('hotels')
        .doc(hotelId)
        .collection('dishes')
        .doc(id)
        .delete();
  }

  Future<void> deleteDishes(String hotelId, List<String> ids) async {
    final batch = _db.batch();
    for (final id in ids) {
      batch.delete(
        _db.collection('hotels').doc(hotelId).collection('dishes').doc(id),
      );
    }
    await batch.commit();
  }
}

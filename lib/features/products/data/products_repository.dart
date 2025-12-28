import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ftrace_web/features/users/model/users_model.dart';
import '../model/product_model.dart';

class ProductsRepository {
  final _db = FirebaseFirestore.instance;

  Stream<List<ProductModel>> fetchProducts(
    String? hotelId, {
    String? query,
    String? supplier,
    String? uom,
    String? inventoryUom,
    String? category,
    UserModel? currentUser,
  }) {
    Query collectionRef;

    if (hotelId != null && hotelId.isNotEmpty) {
      collectionRef = _db
          .collection('hotels')
          .doc(hotelId)
          .collection('products');
    } else {
      // 🔹 Apply Role-Based Filtering for Global Search
      collectionRef = _db.collectionGroup('products');
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
      var list = snap.docs
          .where((doc) => doc.reference.path.split('/').length == 4)
          .map(
            (doc) => ProductModel.fromDoc(
              doc.id,
              doc.data() as Map<String, dynamic>,
            ),
          )
          .toList();

      // Client-side filtering
      if (supplier != null && supplier.isNotEmpty) {
        list = list.where((p) => p.supplier == supplier).toList();
      }
      if (uom != null && uom.isNotEmpty) {
        list = list.where((p) => p.uom == uom).toList();
      }
      if (inventoryUom != null && inventoryUom.isNotEmpty) {
        list = list.where((p) => p.inventoryUom == inventoryUom).toList();
      }
      if (category != null && category.isNotEmpty) {
        list = list.where((p) => p.categories.contains(category)).toList();
      }

      // Client-side sorting
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      if (query == null || query.isEmpty) return list;
      final q = query.toLowerCase();
      return list
          .where(
            (p) =>
                p.name.toLowerCase().contains(q) ||
                p.barcode.toLowerCase().contains(q) ||
                p.supplier.toLowerCase().contains(q),
          )
          .toList();
    });
  }

  Future<void> addProduct(ProductModel product) async {
    await _db
        .collection('hotels')
        .doc(product.hotelId)
        .collection('products')
        .add(product.toJson());
  }

  Future<void> bulkAddProducts(List<ProductModel> products) async {
    // Group products by hotelId because they go into different subcollections
    final Map<String, List<ProductModel>> byHotel = {};
    for (var p in products) {
      if (!byHotel.containsKey(p.hotelId)) {
        byHotel[p.hotelId] = [];
      }
      byHotel[p.hotelId]!.add(p);
    }

    for (var entry in byHotel.entries) {
      final hotelId = entry.key;
      final hotelProducts = entry.value;

      // Firestore batch limit is 500
      for (var i = 0; i < hotelProducts.length; i += 500) {
        final batch = _db.batch();
        final chunk = hotelProducts.skip(i).take(500);

        for (var p in chunk) {
          final docRef = _db
              .collection('hotels')
              .doc(hotelId)
              .collection('products')
              .doc();
          batch.set(docRef, p.toJson());
        }
        await batch.commit();
      }
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    await _db
        .collection('hotels')
        .doc(product.hotelId)
        .collection('products')
        .doc(product.id)
        .update(product.toJson());
  }

  Future<void> deleteProduct(String hotelId, String id) async {
    await _db
        .collection('hotels')
        .doc(hotelId)
        .collection('products')
        .doc(id)
        .delete();
  }

  Future<void> deleteProducts(String hotelId, List<String> ids) async {
    final batch = _db.batch();
    for (final id in ids) {
      batch.delete(
        _db.collection('hotels').doc(hotelId).collection('products').doc(id),
      );
    }
    await batch.commit();
  }
}

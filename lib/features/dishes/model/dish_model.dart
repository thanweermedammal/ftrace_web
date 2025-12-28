import 'package:cloud_firestore/cloud_firestore.dart';

class RecipeItem {
  final String productId;
  final String productName;
  final double quantity;
  final String unit;

  RecipeItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
  });

  factory RecipeItem.fromJson(Map<String, dynamic> json) {
    return RecipeItem(
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: (json['quantity'] ?? 0.0).toDouble(),
      unit: json['unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unit': unit,
    };
  }
}

class DishModel {
  final String id;
  final String name;
  final List<String> allergens;
  final String imageUrl;
  final List<RecipeItem> recipeItems;
  final List<String> preCookedItemIds;
  final String hotelId;
  final String hotelName;
  final DateTime? createdAt;

  DishModel({
    required this.id,
    required this.name,
    required this.allergens,
    required this.imageUrl,
    required this.recipeItems,
    required this.preCookedItemIds,
    this.hotelId = '',
    this.hotelName = '',
    this.createdAt,
  });

  factory DishModel.fromDoc(String id, Map<String, dynamic> doc) {
    return DishModel(
      id: id,
      name: doc['name'] ?? '',
      allergens: doc['allergens'] is Iterable
          ? List<String>.from(doc['allergens'])
          : [],
      imageUrl: doc['imageUrl'] ?? '',
      recipeItems: doc['recipeItems'] is List
          ? (doc['recipeItems'] as List)
                .map((item) => RecipeItem.fromJson(item))
                .toList()
          : [],
      preCookedItemIds: doc['preCookedItemIds'] is Iterable
          ? List<String>.from(doc['preCookedItemIds'])
          : [],
      hotelId: doc['hotelId'] ?? '',
      hotelName: doc['hotelName'] ?? '',
      createdAt: (doc['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'allergens': allergens,
      'imageUrl': imageUrl,
      'recipeItems': recipeItems.map((item) => item.toJson()).toList(),
      'preCookedItemIds': preCookedItemIds,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

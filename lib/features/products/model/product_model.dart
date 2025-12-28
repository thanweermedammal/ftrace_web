import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  static const List<String> uomOptions = [
    'GRAM',
    'KG',
    'LITRE',
    'ML',
    'PACK',
    'PIECE',
    // 'BOX',
    // 'BOTTLE',
    // 'CAN',
    // 'UNIT',
    // 'PORTION',
    // 'CASE',
    // 'BAG',
    // 'DOZEN',
    // 'ROLL',
  ];

  final String id;
  final String name;
  final String barcode;
  final String description;
  final String uom;
  final String inventoryUom;
  final double conversionFactor;
  final String status;
  final String supplier;
  final List<String> categories;
  final double quantity;
  final String hotelId;
  final String hotelName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    this.barcode = '',
    this.description = '',
    required this.uom,
    required this.inventoryUom,
    this.conversionFactor = 1.0,
    this.status = 'ACTIVE',
    required this.supplier,
    required this.categories,
    this.quantity = 0.0,
    this.hotelId = '',
    this.hotelName = '',
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromDoc(String id, Map<String, dynamic> doc) {
    return ProductModel(
      id: id,
      name: doc['name'] ?? '',
      barcode: doc['barcode'] ?? '',
      description: doc['description'] ?? '',
      uom: doc['uom'] ?? '',
      inventoryUom: doc['inventoryUom'] ?? '',
      conversionFactor: (doc['conversionFactor'] ?? 1.0).toDouble(),
      status: doc['status'] ?? 'ACTIVE',
      supplier: doc['supplier'] ?? '',
      categories: List<String>.from(doc['categories'] ?? []),
      quantity: (doc['quantity'] ?? 0.0).toDouble(),
      hotelId: doc['hotelId'] ?? '',
      hotelName: doc['hotelName'] ?? '',
      createdAt: (doc['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (doc['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'barcode': barcode,
      'description': description,
      'uom': uom,
      'inventoryUom': inventoryUom,
      'conversionFactor': conversionFactor,
      'status': status,
      'supplier': supplier,
      'categories': categories,
      'quantity': quantity,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? barcode,
    String? description,
    String? uom,
    String? inventoryUom,
    double? conversionFactor,
    String? status,
    String? supplier,
    List<String>? categories,
    double? quantity,
    String? hotelId,
    String? hotelName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      uom: uom ?? this.uom,
      inventoryUom: inventoryUom ?? this.inventoryUom,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      status: status ?? this.status,
      supplier: supplier ?? this.supplier,
      categories: categories ?? this.categories,
      quantity: quantity ?? this.quantity,
      hotelId: hotelId ?? this.hotelId,
      hotelName: hotelName ?? this.hotelName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

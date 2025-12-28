import 'package:cloud_firestore/cloud_firestore.dart';

class ReceivingModel {
  final String id;
  final String barcode;
  final String invoiceNo;
  final String product;
  final double quantity;
  final DateTime? expiryDate;
  final DateTime? productionDate;
  final String hotelId;
  final String hotelName;
  final String receivedBy;
  final DateTime? createdAt;

  ReceivingModel({
    required this.id,
    required this.barcode,
    required this.invoiceNo,
    required this.product,
    required this.quantity,
    this.expiryDate,
    this.productionDate,
    required this.hotelName,
    required this.hotelId,
    required this.receivedBy,
    this.createdAt,
  });

  factory ReceivingModel.fromDoc(String id, Map<String, dynamic> doc) {
    return ReceivingModel(
      id: id,
      barcode: doc['barcode'] ?? '',
      invoiceNo: doc['invoiceNo'] ?? '',
      product: doc['product'] ?? '',
      quantity: (doc['quantity'] ?? 0.0).toDouble(),
      expiryDate: (doc['expiryDate'] as Timestamp?)?.toDate(),
      productionDate: (doc['productionDate'] as Timestamp?)?.toDate(),
      hotelId: doc['hotelId'] ?? '',
      hotelName: doc['hotelName'] ?? '',
      receivedBy: doc['receivedBy'] ?? '',
      createdAt: (doc['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'invoiceNo': invoiceNo,
      'product': product,
      'quantity': quantity,
      'expiryDate': expiryDate,
      'productionDate': productionDate,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'receivedBy': receivedBy,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class KitchenStorageModel {
  final String id;
  final DateTime date;
  final String product;
  final String barcode;
  final double quantity;
  final String hotelId;
  final String hotelName;
  final String kitchenName;
  final String storageName;
  final String movedBy;

  KitchenStorageModel({
    required this.id,
    required this.date,
    required this.product,
    required this.barcode,
    required this.quantity,
    required this.hotelId,
    required this.hotelName,
    required this.kitchenName,
    required this.storageName,
    required this.movedBy,
  });

  factory KitchenStorageModel.fromDoc(String id, Map<String, dynamic> doc) {
    return KitchenStorageModel(
      id: id,
      date: (doc['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      product: doc['product'] ?? '',
      barcode: doc['barcode'] ?? '',
      quantity: (doc['quantity'] ?? 0.0).toDouble(),
      hotelId: doc['hotelId'] ?? '',
      hotelName: doc['hotelName'] ?? '',
      kitchenName: doc['kitchenName'] ?? '',
      storageName: doc['storageName'] ?? '',
      movedBy: doc['movedBy'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'product': product,
      'barcode': barcode,
      'quantity': quantity,
      'hotelId': hotelId,
      'hotelName': hotelName,
      'kitchenName': kitchenName,
      'storageName': storageName,
      'movedBy': movedBy,
    };
  }
}

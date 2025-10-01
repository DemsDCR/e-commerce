import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/models/cart_item_model.dart';
import 'package:login/models/product_model.dart';

enum OrderStatus { pending, confirmed, shipped, delivered, cancelled }

class OrderModel {
  final String? id;
  final String userId;
  final List<CartItemModel> items;
  final double totalAmount;
  final OrderStatus status;
  final String shippingAddress;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.createdAt,
    this.updatedAt,
  });

  // Créer un OrderModel depuis un document Firestore
  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => CartItemModel(
                productId: item['productId'],
                product: ProductModel.fromFirestore(item['product']),
                quantity: item['quantity'],
              ))
          .toList() ?? [],
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      shippingAddress: data['shippingAddress'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  // Convertir un OrderModel en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => {
        'productId': item.productId,
        'product': item.product.toFirestore(),
        'quantity': item.quantity,
      }).toList(),
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'shippingAddress': shippingAddress,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Créer une copie avec des modifications
  OrderModel copyWith({
    String? id,
    String? userId,
    List<CartItemModel>? items,
    double? totalAmount,
    OrderStatus? status,
    String? shippingAddress,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'OrderModel(id: $id, userId: $userId, totalAmount: $totalAmount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderModel &&
        other.id == id &&
        other.userId == userId &&
        other.totalAmount == totalAmount;
  }

  @override
  int get hashCode {
    return id.hashCode ^ userId.hashCode ^ totalAmount.hashCode;
  }
}

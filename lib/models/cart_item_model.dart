import 'package:login/models/product_model.dart';

class CartItemModel {
  final String productId;
  final ProductModel product;
  final int quantity;
  final double totalPrice;

  CartItemModel({
    required this.productId,
    required this.product,
    required this.quantity,
  }) : totalPrice = product.price * quantity;

  // Créer une copie avec des modifications
  CartItemModel copyWith({
    String? productId,
    ProductModel? product,
    int? quantity,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  String toString() {
    return 'CartItemModel(productId: $productId, quantity: $quantity, totalPrice: $totalPrice)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartItemModel &&
        other.productId == productId &&
        other.quantity == quantity;
  }

  @override
  int get hashCode {
    return productId.hashCode ^ quantity.hashCode;
  }
}

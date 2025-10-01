import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/models/cart_item_model.dart';
import 'package:login/models/product_model.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'carts';

  // Ajouter un produit au panier
  Future<void> addToCart(String userId, String productId, int quantity) async {
    try {
      // Vérifier si le produit existe déjà dans le panier
      DocumentSnapshot cartDoc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();

      Map<String, dynamic> cartData = cartDoc.data() as Map<String, dynamic>? ?? {};
      List<dynamic> items = cartData['items'] ?? [];

      // Chercher si le produit existe déjà
      int existingIndex = items.indexWhere((item) => item['productId'] == productId);

      if (existingIndex != -1) {
        // Mettre à jour la quantité
        items[existingIndex]['quantity'] = (items[existingIndex]['quantity'] ?? 0) + quantity;
      } else {
        // Ajouter un nouvel item
        items.add({
          'productId': productId,
          'quantity': quantity,
        });
      }

      // Sauvegarder le panier
      await _firestore
          .collection(_collection)
          .doc(userId)
          .set({
        'items': items,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout au panier: $e');
    }
  }

  // Obtenir le panier d'un utilisateur
  Future<List<CartItemModel>> getCart(String userId) async {
    try {
      DocumentSnapshot cartDoc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();

      if (!cartDoc.exists) {
        return [];
      }

      Map<String, dynamic> cartData = cartDoc.data() as Map<String, dynamic>;
      List<dynamic> items = cartData['items'] ?? [];

      List<CartItemModel> cartItems = [];

      for (var item in items) {
        String productId = item['productId'];
        int quantity = item['quantity'] ?? 0;

        // Récupérer les détails du produit
        DocumentSnapshot productDoc = await _firestore
            .collection('products')
            .doc(productId)
            .get();

        if (productDoc.exists) {
          ProductModel product = ProductModel.fromFirestore(productDoc);
          cartItems.add(CartItemModel(
            productId: productId,
            product: product,
            quantity: quantity,
          ));
        }
      }

      return cartItems;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du panier: $e');
    }
  }

  // Mettre à jour la quantité d'un produit dans le panier
  Future<void> updateQuantity(String userId, String productId, int quantity) async {
    try {
      DocumentSnapshot cartDoc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();

      Map<String, dynamic> cartData = cartDoc.data() as Map<String, dynamic>? ?? {};
      List<dynamic> items = cartData['items'] ?? [];

      int existingIndex = items.indexWhere((item) => item['productId'] == productId);

      if (existingIndex != -1) {
        if (quantity <= 0) {
          // Supprimer l'item si la quantité est 0 ou moins
          items.removeAt(existingIndex);
        } else {
          // Mettre à jour la quantité
          items[existingIndex]['quantity'] = quantity;
        }

        await _firestore
            .collection(_collection)
            .doc(userId)
            .set({
          'items': items,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la quantité: $e');
    }
  }

  // Supprimer un produit du panier
  Future<void> removeFromCart(String userId, String productId) async {
    try {
      DocumentSnapshot cartDoc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();

      Map<String, dynamic> cartData = cartDoc.data() as Map<String, dynamic>? ?? {};
      List<dynamic> items = cartData['items'] ?? [];

      items.removeWhere((item) => item['productId'] == productId);

      await _firestore
          .collection(_collection)
          .doc(userId)
          .set({
        'items': items,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Erreur lors de la suppression du produit: $e');
    }
  }

  // Vider le panier
  Future<void> clearCart(String userId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Erreur lors du vidage du panier: $e');
    }
  }

  // Obtenir le nombre total d'articles dans le panier
  Future<int> getCartItemCount(String userId) async {
    try {
      List<CartItemModel> cartItems = await getCart(userId);
      int total = 0;
      for (var item in cartItems) {
        total += item.quantity;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  // Calculer le total du panier
  Future<double> getCartTotal(String userId) async {
    try {
      List<CartItemModel> cartItems = await getCart(userId);
      double total = 0.0;
      for (var item in cartItems) {
        total += item.totalPrice;
      }
      return total;
    } catch (e) {
      return 0.0;
    }
  }

  // Stream du panier pour les mises à jour en temps réel
  Stream<List<CartItemModel>> getCartStream(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (!snapshot.exists) {
        return <CartItemModel>[];
      }

      Map<String, dynamic> cartData = snapshot.data() as Map<String, dynamic>;
      List<dynamic> items = cartData['items'] ?? [];

      List<CartItemModel> cartItems = [];

      for (var item in items) {
        String productId = item['productId'];
        int quantity = item['quantity'] ?? 0;

        try {
          DocumentSnapshot productDoc = await _firestore
              .collection('products')
              .doc(productId)
              .get();

          if (productDoc.exists) {
            ProductModel product = ProductModel.fromFirestore(productDoc);
            cartItems.add(CartItemModel(
              productId: productId,
              product: product,
              quantity: quantity,
            ));
          }
        } catch (e) {
          // Ignorer les produits qui n'existent plus
          continue;
        }
      }

      return cartItems;
    });
  }
}

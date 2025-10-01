import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/models/order_model.dart';
import 'package:login/models/cart_item_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  // Créer une nouvelle commande
  Future<String> createOrder({
    required String userId,
    required List<CartItemModel> items,
    required String shippingAddress,
  }) async {
    try {
      double totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);

      OrderModel order = OrderModel(
        userId: userId,
        items: items,
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        shippingAddress: shippingAddress,
        createdAt: DateTime.now(),
      );

      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(order.toFirestore());

      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de la création de la commande: $e');
    }
  }

  // Obtenir les commandes d'un utilisateur
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    });
  }

  // Obtenir toutes les commandes (pour les admins)
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    });
  }

  // Obtenir une commande par ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(orderId)
          .get();
      
      if (doc.exists) {
        return OrderModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la commande: $e');
    }
  }

  // Mettre à jour le statut d'une commande
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(orderId)
          .update({
        'status': status.toString().split('.').last,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du statut: $e');
    }
  }

  // Annuler une commande
  Future<void> cancelOrder(String orderId) async {
    try {
      await updateOrderStatus(orderId, OrderStatus.cancelled);
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation de la commande: $e');
    }
  }

  // Obtenir les commandes par statut
  Stream<List<OrderModel>> getOrdersByStatus(OrderStatus status) {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: status.toString().split('.').last)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => OrderModel.fromFirestore(doc))
          .toList();
    });
  }

  // Obtenir les statistiques des commandes (pour les admins)
  Future<Map<String, int>> getOrderStats() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(_collection).get();
      
      Map<String, int> stats = {
        'total': 0,
        'pending': 0,
        'confirmed': 0,
        'shipped': 0,
        'delivered': 0,
        'cancelled': 0,
      };

      for (var doc in snapshot.docs) {
        OrderModel order = OrderModel.fromFirestore(doc);
        stats['total'] = (stats['total'] ?? 0) + 1;
        
        String status = order.status.toString().split('.').last;
        stats[status] = (stats[status] ?? 0) + 1;
      }

      return stats;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des statistiques: $e');
    }
  }

  // Obtenir le chiffre d'affaires total
  Future<double> getTotalRevenue() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('status', whereIn: ['confirmed', 'shipped', 'delivered'])
          .get();
      
      double total = 0.0;
      for (var doc in snapshot.docs) {
        OrderModel order = OrderModel.fromFirestore(doc);
        total += order.totalAmount;
      }

      return total;
    } catch (e) {
      throw Exception('Erreur lors du calcul du chiffre d\'affaires: $e');
    }
  }
}

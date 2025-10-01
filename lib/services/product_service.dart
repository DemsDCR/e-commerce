import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Ajouter un produit
  Future<String> addProduct(ProductModel product) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(_collection)
          .add(product.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du produit: $e');
    }
  }

  // Obtenir tous les produits
  Stream<List<ProductModel>> getProducts() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  // Obtenir les produits par catégorie
  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .where('isAvailable', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  // Obtenir un produit par ID
  Future<ProductModel?> getProductById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();
      
      if (doc.exists) {
        return ProductModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du produit: $e');
    }
  }

  // Mettre à jour un produit
  Future<void> updateProduct(String id, ProductModel product) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update(product.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du produit: $e');
    }
  }

  // Supprimer un produit
  Future<void> deleteProduct(String id) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du produit: $e');
    }
  }

  // Rechercher des produits
  Stream<List<ProductModel>> searchProducts(String query) {
    return _firestore
        .collection(_collection)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()) ||
              product.category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  // Obtenir les catégories disponibles
  Future<List<String>> getCategories() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('isAvailable', isEqualTo: true)
          .get();
      
      Set<String> categories = {};
      for (var doc in snapshot.docs) {
        ProductModel product = ProductModel.fromFirestore(doc);
        categories.add(product.category);
      }
      
      return categories.toList()..sort();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des catégories: $e');
    }
  }

  // Mettre à jour le stock d'un produit
  Future<void> updateProductStock(String id, int newStock) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({
        'stock': newStock,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du stock: $e');
    }
  }

  // Marquer un produit comme disponible/indisponible
  Future<void> toggleProductAvailability(String id, bool isAvailable) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({
        'isAvailable': isAvailable,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour de la disponibilité: $e');
    }
  }
}

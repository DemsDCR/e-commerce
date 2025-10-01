import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import '../models/users.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  // Collection reference
  CollectionReference get usersCollection => _firestore.collection('users');

  // Créer un nouvel utilisateur
  Future<bool> createUser(UserModel user) async {
    try {
      await usersCollection.doc(user.id).set(user.toFirestore());
      return true;
    } catch (e) {
      print('Erreur lors de la création de l\'utilisateur: $e');
      return false;
    }
  }

  // Récupérer un utilisateur par ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  // Récupérer l'utilisateur connecté
  Future<UserModel?> getCurrentUser() async {
    try {
      auth.User? firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        return await getUserById(firebaseUser.uid);
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de l\'utilisateur connecté: $e');
      return null;
    }
  }

  // Mettre à jour un utilisateur
  Future<bool> updateUser(UserModel user) async {
    try {
      await usersCollection.doc(user.id).update(user.toFirestore());
      return true;
    } catch (e) {
      print('Erreur lors de la mise à jour de l\'utilisateur: $e');
      return false;
    }
  }

  // Supprimer un utilisateur
  Future<bool> deleteUser(String userId) async {
    try {
      await usersCollection.doc(userId).delete();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de l\'utilisateur: $e');
      return false;
    }
  }

  // Récupérer tous les utilisateurs
  Stream<List<UserModel>> getAllUsers() {
    return usersCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  // Rechercher des utilisateurs par nom
  Future<List<UserModel>> searchUsersByName(String searchTerm) async {
    try {
      QuerySnapshot snapshot = await usersCollection
          .where('nom', isGreaterThanOrEqualTo: searchTerm)
          .where('nom', isLessThan: searchTerm + '\uf8ff')
          .get();
      
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erreur lors de la recherche d\'utilisateurs: $e');
      return [];
    }
  }

  // Vérifier si un email existe déjà
  Future<bool> emailExists(String email) async {
    try {
      QuerySnapshot snapshot = await usersCollection
          .where('email', isEqualTo: email)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la vérification de l\'email: $e');
      return false;
    }
  }
} 

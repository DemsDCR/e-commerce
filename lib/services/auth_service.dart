import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/models/users.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtenir l'utilisateur actuel
  User? get currentUser => _auth.currentUser;

  // Stream de l'utilisateur actuel
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Connexion avec email et mot de passe
  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        return await getUserData(result.user!.uid);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Inscription avec email et mot de passe
  Future<UserModel?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String nom,
    required String prenom,
    required String address,
    UserRole role = UserRole.client,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (result.user != null) {
        UserModel userModel = UserModel(
          id: result.user!.uid,
          nom: nom,
          prenom: prenom,
          address: address,
          email: email,
          role: role,
          dateCreation: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(result.user!.uid)
            .set(userModel.toFirestore());

        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Erreur d\'inscription: $e');
    }
  }

  // Obtenir les données utilisateur depuis Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération des données: $e');
    }
  }

  // Mettre à jour les données utilisateur
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour: $e');
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Erreur de déconnexion: $e');
    }
  }

  // Vérifier si l'utilisateur est admin
  Future<bool> isAdmin(String uid) async {
    try {
      UserModel? user = await getUserData(uid);
      return user?.role == UserRole.admin;
    } catch (e) {
      return false;
    }
  }

  // Vérifier si l'utilisateur est client
  Future<bool> isClient(String uid) async {
    try {
      UserModel? user = await getUserData(uid);
      return user?.role == UserRole.client;
    } catch (e) {
      return false;
    }
  }

  // Obtenir le rôle de l'utilisateur
  Future<UserRole?> getUserRole(String uid) async {
    try {
      UserModel? user = await getUserData(uid);
      return user?.role;
    } catch (e) {
      return null;
    }
  }
}

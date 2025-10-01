import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, client }

class UserModel {
  final String? id;
  final String nom;
  final String prenom;
  final String address;
  final String email;
  final UserRole role;
  final DateTime dateCreation;

  UserModel({
    this.id,
    required this.nom,
    required this.prenom,
    required this.address,
    required this.email,
    required this.role,
    required this.dateCreation,
  });

  // Créer un UserModel depuis un document Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      nom: data['nom'] ?? '',
      prenom: data['prenom'] ?? '',
      address: data['address'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == data['role'],
        orElse: () => UserRole.client,
      ),
      dateCreation: (data['dateCreation'] as Timestamp).toDate(),
    );
  }

  // Convertir un UserModel en Map pour Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'prenom': prenom,
      'address': address,
      'email': email,
      'role': role.toString().split('.').last,
      'dateCreation': Timestamp.fromDate(dateCreation),
    };
  }

  // Créer une copie avec des modifications
  UserModel copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? address,
    String? email,
    UserRole? role,
    DateTime? dateCreation,
  }) {
    return UserModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      address: address ?? this.address,
      email: email ?? this.email,
      role: role ?? this.role,
      dateCreation: dateCreation ?? this.dateCreation,
    );
  }

  // Obtenir le nom complet
  String get nomComplet => '$nom $prenom';

  @override
  String toString() {
    return 'UserModel(id: $id, nom: $nom, prenom: $prenom, address: $address, email: $email, dateCreation: $dateCreation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.nom == nom &&
        other.prenom == prenom &&
        other.address == address &&
        other.email == email &&
        other.dateCreation == dateCreation;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        nom.hashCode ^
        prenom.hashCode ^
        address.hashCode ^
        email.hashCode ^
        dateCreation.hashCode;
  }
}

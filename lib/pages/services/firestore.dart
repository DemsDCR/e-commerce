import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  // Référence à la collection users
  final CollectionReference notes =
      FirebaseFirestore.instance.collection('notes');


  // CREATE : ajouter une user
  Future<bool> addUsers(String note) async {
    try {
      await notes.add({
        'note': note,
        'timestamp': Timestamp.now(),
      });
      return true; // Succès
    } catch (e) {
      print('Erreur lors de l\'ajout de la note: $e');
      return false; // Échec
    }
  }

  // READ : récupérer les users en temps réel
  Stream<QuerySnapshot> getUsersStream() {
    final notesStream =
        notes.orderBy('timestamp', descending: true).snapshots();
    return notesStream;
  }

  //  UPDATE : mettre à jour un user
  Future<bool> updateUsers(String docID, String newNote) async {
    try {
      await notes.doc(docID).update({
        'note': newNote,
        'timestamp': Timestamp.now(), // Mettre à jour la date si tu veux
      });
      return true; // Succès
    } catch (e) {
      print('Erreur lors de la mise à jour du user: $e');
      return false; // Échec
    }
  }

  //  DELETE : supprimer une personne
  Future<bool> deleteUsers(String docID) async {
    try {
      await notes.doc(docID).delete();
      return true; // Succès
    } catch (e) {
      print('Erreur lors de la suppression de la note: $e');
      return false; // Échec
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestService {
  static Future<bool> testFirebaseConnection() async {
    try {
      // Test de connexion basique
      await FirebaseFirestore.instance.collection('test').doc('test').get();
      print(' Connexion Firebase réussie');
      return true;
    } catch (e) {
      print(' Erreur de connexion Firebase: $e');
      return false;
    }
  }

  static Future<bool> testWritePermission() async {
    try {
      // Test d'écriture
      await FirebaseFirestore.instance
          .collection('test')
          .doc('write_test')
          .set({
        'test': 'write_permission',
        'timestamp': Timestamp.now(),
      });
      print(' Permissions d\'écriture OK');
      return true;
    } catch (e) {
      print(' Erreur de permissions d\'écriture: $e');
      return false;
    }
  }

  static Future<bool> testReadPermission() async {
    try {
      // Test de lecture
      await FirebaseFirestore.instance
          .collection('test')
          .doc('write_test')
          .get();
      print(' Permissions de lecture OK');
      return true;
    } catch (e) {
      print(' Erreur de permissions de lecture: $e');
      return false;
    }
  }

  static Future<void> runAllTests() async {
    print(' Début des tests Firebase...');
    
    bool connection = await testFirebaseConnection();
    if (connection) {
      await testWritePermission();
      await testReadPermission();
    }
    
    print(' Tests terminés');
  }
} 

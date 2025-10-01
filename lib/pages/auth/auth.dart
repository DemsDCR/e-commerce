// Cleaned: removed old commented-out implementation to keep file concise.
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/services/auth_service.dart';
import 'package:login/models/users.dart';
import 'package:login/pages/auth/registre.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final _usernamecontroller = TextEditingController();
  final _passwordController = TextEditingController();
  // No direct field; AuthService instances are created where needed to keep code simple
  bool _isobscur = true;
  String message = '';

  Future<void> login() async {
    final authService = AuthService();
    try {
      final userModel = await authService.signInWithEmailAndPassword(
        _usernamecontroller.text.trim(),
        _passwordController.text.trim(),
      );
      if (userModel == null) {
        // No Firestore user doc exists for this uid. Create a minimal record so
        // the app can continue (default to client role). This commonly happens
        // when the Firebase Auth account exists but the users collection was
        // never populated (older accounts, migrations, or manual sign-ins).
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Impossible de récupérer les données utilisateur.')),
          );
          return;
        }

        final docRef = FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid);
        await docRef.set({
          'nom': firebaseUser.displayName ?? '',
          'prenom': '',
          'address': '',
          'email': firebaseUser.email ?? _usernamecontroller.text.trim(),
          'role': UserRole.client.toString().split('.').last,
          'dateCreation': Timestamp.fromDate(DateTime.now()),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Connexion réussie !"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pushReplacementNamed(context, '/client');
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Connexion réussie !"),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Rediriger selon le rôle
      switch (userModel.role) {
        case UserRole.admin:
          Navigator.pushReplacementNamed(context, '/admin');
          break;
        case UserRole.client:
          Navigator.pushReplacementNamed(context, '/client');
          break;
      }
    } on FirebaseAuthException catch (e) {
      String error = 'Erreur lors de la connexion.';
      if (e.code == 'user-not-found') {
        error = 'Utilisateur non trouvé pour cet email.';
      } else if (e.code == 'wrong-password') {
        error = 'Mot de passe incorrect.';
      } else if (e.message != null) {
        error = e.message!;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [const Icon(Icons.error), const SizedBox(width: 8), Expanded(child: Text(error))],
          ),
        ),
      );
      return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [const Icon(Icons.error), Expanded(child: Text("Erreur : $e"))],
          ),
        ),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        centerTitle: true,
        title: const Text("DEMS-STORE", style: TextStyle(color: Colors.white),),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    "Bienvenue",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Connectez-vous avec votre email et mot de passe pour continuer avec nous",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  // const SizedBox(height: 16),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  AuthForm(
                    usernameController: _usernamecontroller,
                    passwordController: _passwordController,
                    isObscur: _isobscur,
                    toggleObscur: () {
                      setState(() {
                        _isobscur = !_isobscur;
                      });
                    },
                    onSubmit: login,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                ],
              ),
            ),
          ),
        ),
      )
    );
    }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

class AuthForm extends StatelessWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isObscur;
  final VoidCallback toggleObscur;
  final Future<void> Function() onSubmit;

  const AuthForm({
    Key? key,
    required this.usernameController,
    required this.passwordController,
    required this.isObscur,
    required this.toggleObscur,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            onSaved: (email) {},
            onChanged: (email) {},
            controller: usernameController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Enter your email",
              labelText: "Email",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              suffixIcon: const Icon(Icons.mail, color: Color(0xFF757575)),
              border: authOutlineInputBorder,
              enabledBorder: authOutlineInputBorder,
              focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFFFF7643)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: TextFormField(
              onSaved: (password) {},
              onChanged: (password) {},
              obscureText: isObscur,
              controller: passwordController,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: "Enter your password",
                labelText: "Password",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle: const TextStyle(color: Color(0xFF757575)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isObscur ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: toggleObscur,
                ),
                border: authOutlineInputBorder,
                enabledBorder: authOutlineInputBorder,
                focusedBorder: authOutlineInputBorder.copyWith(
                  borderSide: const BorderSide(color: Color(0xFFFF7643)),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              await onSubmit();
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: const Color(0xFFFF7643),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 48),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            child: const Text("Continue"),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Registre()),
              );
            },
            child: const Text(
              "Créer un compte",
              style: TextStyle(
                color: Color(0xFFFF7643),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }
}

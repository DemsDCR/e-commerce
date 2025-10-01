import 'package:flutter/material.dart';
import 'package:login/services/auth_service.dart';
import 'package:login/models/users.dart';

class Registre extends StatefulWidget {
  const Registre({super.key});

  @override
  State<Registre> createState() => _RegState();
}

class _RegState extends State<Registre> {
  final _nom_complet = TextEditingController();
  final _prenom = TextEditingController();
  final _address = TextEditingController();
  final _usernamecontroller = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  
  String message = '';

  Future<void> register() async {
    try {
      final userModel = await _authService.createUserWithEmailAndPassword(
        email: _usernamecontroller.text.trim(),
        password: _passwordController.text.trim(),
        nom: _nom_complet.text.trim(),
        prenom: _prenom.text.trim(),
        address: _address.text.trim(),
        role: UserRole.client,
      );

      if (userModel == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la création du compte.')),
        );
        return;
      }

      // Redirect according to role
      if (!mounted) return;
      switch (userModel.role) {
        case UserRole.admin:
          Navigator.pushReplacementNamed(context, '/admin');
          break;
        case UserRole.client:
          Navigator.pushReplacementNamed(context, '/client');
          break;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
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
        title: const Text("DEMS-STORE", style: TextStyle(color: Colors.white)),
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
                    "Créer un compte",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Remplissez les informations ci-dessous pour créer votre compte",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  RegisterForm(
                    nomController: _nom_complet,
                    prenomController: _prenom,
                    addressController: _address,
                    emailController: _usernamecontroller,
                    passwordController: _passwordController,
                    onSubmit: register,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const registerOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

class RegisterForm extends StatelessWidget {
  final TextEditingController nomController;
  final TextEditingController prenomController;
  final TextEditingController addressController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Future<void> Function() onSubmit;

  const RegisterForm({
    Key? key,
    required this.nomController,
    required this.prenomController,
    required this.addressController,
    required this.emailController,
    required this.passwordController,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextFormField(
            controller: nomController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              hintText: "Entrez votre nom",
              labelText: "Nom",
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintStyle: const TextStyle(color: Color(0xFF757575)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              suffixIcon: const Icon(Icons.person, color: Color(0xFF757575)),
              border: registerOutlineInputBorder,
              enabledBorder: registerOutlineInputBorder,
              focusedBorder: registerOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Color(0xFFFF7643)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: TextFormField(
              controller: prenomController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: "Entrez votre prénom",
                labelText: "Prénom",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle: const TextStyle(color: Color(0xFF757575)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                suffixIcon: const Icon(Icons.person_outline, color: Color(0xFF757575)),
                border: registerOutlineInputBorder,
                enabledBorder: registerOutlineInputBorder,
                focusedBorder: registerOutlineInputBorder.copyWith(
                  borderSide: const BorderSide(color: Color(0xFFFF7643)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: TextFormField(
              controller: addressController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: "Entrez votre adresse",
                labelText: "Adresse",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle: const TextStyle(color: Color(0xFF757575)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                suffixIcon: const Icon(Icons.location_on, color: Color(0xFF757575)),
                border: registerOutlineInputBorder,
                enabledBorder: registerOutlineInputBorder,
                focusedBorder: registerOutlineInputBorder.copyWith(
                  borderSide: const BorderSide(color: Color(0xFFFF7643)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: TextFormField(
              controller: emailController,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                hintText: "Entrez votre email",
                labelText: "Email",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle: const TextStyle(color: Color(0xFF757575)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                suffixIcon: const Icon(Icons.mail, color: Color(0xFF757575)),
                border: registerOutlineInputBorder,
                enabledBorder: registerOutlineInputBorder,
                focusedBorder: registerOutlineInputBorder.copyWith(
                  borderSide: const BorderSide(color: Color(0xFFFF7643)),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: TextFormField(
              controller: passwordController,
              textInputAction: TextInputAction.done,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Entrez votre mot de passe",
                labelText: "Mot de passe",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle: const TextStyle(color: Color(0xFF757575)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                suffixIcon: const Icon(Icons.lock, color: Color(0xFF757575)),
                border: registerOutlineInputBorder,
                enabledBorder: registerOutlineInputBorder,
                focusedBorder: registerOutlineInputBorder.copyWith(
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
            child: const Text("Créer le compte"),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              "Déjà un compte ? Se connecter",
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

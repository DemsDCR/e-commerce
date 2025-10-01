import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/firebase_options.dart';
import 'package:login/services/auth_service.dart';
import 'package:login/models/users.dart';
import 'package:login/pages/auth/auth.dart';
import 'package:login/screens/admin/admin_dashboard.dart';
import 'package:login/screens/client/client_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DEMS-STORE',
      theme: ThemeData(
        primarySwatch: Colors.cyan,
        scaffoldBackgroundColor: Colors.grey[200],
        iconTheme: const IconThemeData(
          color: Colors.cyan,
          size: 50,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.cyan,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const Auth(),
        '/admin': (context) => const AdminDashboard(),
        '/client': (context) => const ClientHome(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  User? _user;
  UserModel? _userModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        try {
          final userModel = await _authService.getUserData(user.uid);
          setState(() {
            _user = user;
            _userModel = userModel;
            _isLoading = false;
          });
        } catch (e) {
          setState(() {
            _user = null;
            _userModel = null;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _user = null;
          _userModel = null;
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Vérification de l\'authentification...'),
            ],
          ),
        ),
      );
    }

    if (_user == null || _userModel == null) {
      return const Auth();
    }

    // Redirection selon le rôle
    switch (_userModel!.role) {
      case UserRole.admin:
        return const AdminDashboard();
      case UserRole.client:
        return const ClientHome();
    }
  }
}


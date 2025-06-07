import 'package:flutter/material.dart';
import 'package:fitness/pages/welcome.dart';
import 'package:fitness/pages/screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:fitness/services/auth_service.dart';
import 'package:fitness/pages/loginsignup.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  initializeDateFormatting('fr_FR', null).then((_) {
    runApp(const MainApp());
  });
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint('MainApp build');
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
      // home: const WelcomePage(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<Map<String, dynamic>>? _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _checkAuthAndWelcome();
  }

  Future<Map<String, dynamic>> _checkAuthAndWelcome() async {
    final token = await AuthService.getToken();
    final prefs = await SharedPreferences.getInstance();
    final hasSeenWelcome = prefs.getBool('has_seen_welcome') ?? false;
    return {
      'token': token,
      'hasSeenWelcome': hasSeenWelcome,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          final token = snapshot.data!['token'] as String?;
          final hasSeenWelcome = snapshot.data!['hasSeenWelcome'] as bool;
          if (token != null && token.isNotEmpty) {
            if (!hasSeenWelcome) {
              return const WelcomePage();
            } else {
              return const HomeScreen();
            }
          } else {
            return const LoginSignupPage();
          }
        } else {
          return const LoginSignupPage();
        }
      },
    );
  }
}

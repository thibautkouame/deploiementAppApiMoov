import 'package:flutter/material.dart';
import 'package:fitness/pages/welcome.dart';
import 'package:fitness/pages/screens/welcome_urser_register.dart';
import 'package:fitness/pages/screens/home_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

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
      // home: WelcomePage()
      home: HomeScreen(),
      // home: WelcomeUserRegister(),
    );
  }
}

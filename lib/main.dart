import 'package:flutter/material.dart';
import 'login-signup.dart'; // This is the import that links the files

void main() => runApp(const LoomeeApp());

class LoomeeApp extends StatelessWidget {
  const LoomeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Loomeé',
      theme: ThemeData(
        primaryColor: const Color(0xFF333333),
        // Adding font styling here will apply to the whole app
      ),
      // Here we tell the app to start with the LoginPage from our other file
      home: const LoginPage(),
    );
  }
}
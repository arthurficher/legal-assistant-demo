import 'package:flutter/material.dart';

class RegistrerHome extends StatefulWidget {
  static const routeName = "homeRegister";
  const RegistrerHome({super.key});

  @override
  State<RegistrerHome> createState() => _RegistrerHomeState();
}

class _RegistrerHomeState extends State<RegistrerHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          "Home Page Register"
        ),
      ),
    );
  }
}
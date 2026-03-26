import 'package:flutter/material.dart';
import 'package:flutter_gemini/data/authentication_client.dart';
import 'package:flutter_gemini/screens/home_screen.dart';
import 'package:flutter_gemini/screens/login.dart';
import 'package:get_it/get_it.dart';

class ScreenStart extends StatefulWidget {
  const ScreenStart({super.key});
  @override
  State<ScreenStart> createState() => _SplashPageState();
}

class _SplashPageState extends State<ScreenStart> {
  final _authenticationClient = GetIt.instance<AuthenticationClient>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLogin();
    });
  }

  Future<void> _checkLogin() async {
    final token = await _authenticationClient.accesToken;
    if (token==null) {//si no tenemos una sesion previa
      Navigator.pushReplacementNamed(context, Login.routeName);
      return;
    }//lo siguiente es si ya tenemos una sesion preuia
    Navigator.pushReplacementNamed(context, HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

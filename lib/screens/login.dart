import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gemini/utility/responsive.dart';
import 'package:flutter_gemini/widgets/circle.dart';
import 'package:flutter_gemini/widgets/icon_login.dart';
import 'package:flutter_gemini/widgets/login_form.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  static const routeName = 'login';

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive.of(context);
    final double blueSize = responsive.wp(80);
    final double orangeSize = responsive.wp(57);

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: responsive.height,//la altura en un singlechildscrollview es dinamica, por eso hay que pasarle un valor fijo
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  top: -blueSize*0.4,
                  right: -blueSize*0.2,
                  child: Circle(
                    size: blueSize,
                    colors: [
                      const Color.fromARGB(255, 6, 126, 187),
                      const Color.fromARGB(255, 1, 34, 50)
                    ],
                  ),
                ),
                Positioned(
                  top: -orangeSize*0.55,
                  left: -orangeSize*0.15,
                  child: Circle(
                    size: orangeSize,
                    colors: [
                      const Color.fromARGB(255, 239, 116, 82),
                      const Color.fromARGB(255, 241, 78, 31)
                    ],
                  ),
                ),
                
                Positioned(
                  top: blueSize*0.35,
                  child: Column(
                    children: [
                      IconLogin(
                        size: responsive.wp(28),
                      ),
                      SizedBox(
                        height: responsive.dp(3),
                      ),
                      Text(
                        "Bienvenido", 
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: responsive.dp(1.6),
                          color: Theme.of(context).textTheme.bodyLarge?.color
                        ),
                      ),
                      SizedBox(
                        height: responsive.dp(0.2),
                      ),
                      Text(
                        "Legal Assistant", 
                        textAlign: TextAlign.center,
                        style: GoogleFonts.kanit(
                          fontSize: responsive.dp(3.7),
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color
                        ),
                      ),
                      Text(
                        "Tu asistente legal impulsado por IA", 
                        textAlign: TextAlign.center,
                        style: GoogleFonts.kanit(
                          fontSize: responsive.dp(1.3),
                          color: Theme.of(context).textTheme.bodyMedium?.color
                        ),
                      ),
                    ],
                  ),
                ),
          
                LoginForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

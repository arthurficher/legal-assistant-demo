import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gemini/utility/responsive.dart';
import 'package:flutter_gemini/widgets/avatar_button.dart';
import 'package:flutter_gemini/widgets/circle.dart';
import 'package:flutter_gemini/widgets/icon_login.dart';
import 'package:flutter_gemini/widgets/register_form.dart';
import 'package:google_fonts/google_fonts.dart';

class Register extends StatefulWidget {
  const Register({super.key});
  static const routname = 'register';
  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive.of(context);
    final double blueSize = responsive.wp(88);
    final double orangeSize = responsive.wp(57);

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: responsive
                .height, //la altura en un singlechildscrollview es dinamica, por eso hay que pasarle un valor fijo
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Positioned(
                  top: -blueSize * 0.3,
                  right: -blueSize * 0.2,
                  child: Circle(
                    size: blueSize,
                    colors: [
                      const Color.fromARGB(255, 6, 126, 187),
                      const Color.fromARGB(255, 1, 34, 50)
                    ],
                  ),
                ),
                Positioned(
                  top: -orangeSize * 0.35,
                  left: -orangeSize * 0.15,
                  child: Circle(
                    size: orangeSize,
                    colors: [
                      const Color.fromARGB(255, 239, 116, 82),
                      const Color.fromARGB(255, 241, 78, 31)
                    ],
                  ),
                ),
                Positioned(
                  top: blueSize * 0.22,
                  child: Column(
                    children: [
                      Text(
                        "Completa el Formulario de Registro",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: responsive.dp(2),
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              // Añadir sombra para simular borde
                              offset: Offset(
                                  1.5, 1.5), // Desplazamiento de la sombra
                              blurRadius: 2.0, // Difuminado de la sombra
                              color: Colors.black, // Color del borde/sombra
                            ),
                            Shadow(
                              offset: Offset(-1.5, -1.5),
                              blurRadius: 2.0,
                              color: Colors.black,
                            ),
                            Shadow(
                              offset: Offset(1.5, -1.5),
                              blurRadius: 2.0,
                              color: Colors.black,
                            ),
                            Shadow(
                              offset: Offset(-1.5, 1.5),
                              blurRadius: 2.0,
                              color: Colors.black,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: responsive.dp(0.2),
                      ),
                      AvatarButton(
                        imageSize: responsive.wp(30),
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
                            color: Theme.of(context).textTheme.bodyMedium?.color),
                      ),
                    ],
                  ),
                ),
                Positioned(
                    left: 15,
                    top: 15,
                    child: SafeArea(
                      child: CupertinoButton(
                        color: Colors.black26,
                        padding: EdgeInsets.all(10),
                        borderRadius: BorderRadius.circular(30),
                        child: Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pushNamed(context, 'login');
                        },
                      ),
                    )
                  ),
                RegisterForm(),

              ],
            ),
          ),
        ),
      ),
    );
  }
}

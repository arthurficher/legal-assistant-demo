import 'package:flutter/material.dart';
import 'package:flutter_gemini/api/authentication_api.dart';
import 'package:flutter_gemini/data/authentication_client.dart';
import 'package:flutter_gemini/screens/home_screen.dart';
import 'package:flutter_gemini/screens/register.dart';
import 'package:flutter_gemini/utility/dialogs.dart';
import 'package:flutter_gemini/utility/responsive.dart';
import 'package:flutter_gemini/widgets/input_text.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _authenticationAPI = GetIt.instance<AuthenticationAPI>();
  final _authenticationClient = GetIt.instance<AuthenticationClient>();//se le debe asignar el tipo de valor que se recupera sino sera de tipo dynamic



  GlobalKey<FormState> _formKey = GlobalKey();
  String _email = '', _password = '';
  Logger _logger = Logger();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  bool _obscurePassword = true;

  Future<void> _submit() async {
    setState(() {
      _autoValidateMode = AutovalidateMode.onUserInteraction;
    });
    final bool isOk = _formKey.currentState!.validate();
    if (isOk) {
      ProgressDialog.show(context);
      
      final response = await _authenticationAPI.login(
        email: _email,
        password: _password,
      );
      ProgressDialog.dissmiss(context);
      if (response.data != null) {//hace login
        await _authenticationClient.saveSession(response.data!);//para que espere a que termine de guaradar la sesion
        Navigator.pushNamedAndRemoveUntil(
          context,
          HomeScreen.routeName,
          (_) => false,
        );
      } else {
        String? message = response.error!.message;
        if (response.error!.statusCode == -1) {
          message = "No hay conexión a internet";
        } else if (response.error!.statusCode == 403) {
          message = "Contraseña no válida";
        } else if (response.error!.statusCode == 404) {
          message = "Usuario no encontrado";
        }

        Dialogs.alert(context, title: "ERROR", description: message);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Responsive responsive = Responsive.of(context);

    return Positioned(
      bottom:
          30, //si no le cargo otros valores da error porque el positioned debe ir dentro de un stack
      child: Container(
        constraints: BoxConstraints(
            maxWidth: responsive.isTablet ? 430 : 360,
            minWidth: 350), //para pantallas mas grandes como un tablet
        child: Form(
          key: _formKey,
          autovalidateMode: _autoValidateMode,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ))),
                child: InputText(
                  keyboardType: TextInputType.emailAddress,
                  label: 'Correo Electrónico',
                  borderEnabled: false,
                  fontSize: responsive.dp(1.8),
                  onChanged: (text) {
                    _email = text;
                  },
                  validator: (text) {
                    if (!text!.contains("@")) {
                      return "No es un formato de email";
                    }
                    return null;
                  },
                  fontSizeError: responsive.dp(1.4),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ))),
                child: InputText(
                  obscureText: _obscurePassword,
                  label: 'Contraseña',
                  borderEnabled: false,
                  fontSize: responsive.dp(1.8),
                  onChanged: (text) {
                    _password = text;
                  },
                  validator: (text) {
                    if (text?.trim().length == 0) {
                      return 'Contraseña no válida';
                    }
                    return null;
                  },
                  fontSizeError: responsive.dp(1.4),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10)),
                  child: Center(
                    child: Text(
                      '¿Olvidó su contraseña?',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: responsive.dp(1.5),
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  onPressed: () {},
                ),
              ),
              SizedBox(
                height: responsive.dp(2),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: this._submit,
                  child: Text(
                    'Ingresar',
                    style: TextStyle(
                      fontSize: responsive.dp(1.5),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 15),
                    foregroundColor: Colors.white,
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(
                height: responsive.dp(2),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "¿Nuevo Usuario?",
                    style: TextStyle(
                        fontSize: responsive.dp(1.6),
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'register');
                      },
                      child: Text(
                        'Registrarse',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: responsive.dp(1.8),
                            color: Theme.of(context).colorScheme.primary),
                      ))
                ],
              ),
              SizedBox(
                height: responsive.dp(10),
              )
            ],
          ),
        ),
      ),
    );
  }
}

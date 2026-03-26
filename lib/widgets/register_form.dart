import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gemini/api/authentication_api.dart';
import 'package:flutter_gemini/data/authentication_client.dart';
import 'package:flutter_gemini/screens/registrer_home.dart';
import 'package:flutter_gemini/utility/dialogs.dart';
import 'package:flutter_gemini/utility/responsive.dart';
import 'package:flutter_gemini/widgets/input_text.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<RegisterForm> {
  final _authenticationAPI = GetIt.instance<AuthenticationAPI>();
  final _authenticationClient = GetIt.instance<AuthenticationClient>();


  GlobalKey<FormState> _formKey = GlobalKey();
  String _email = '', _password = '', _userName = '';
  
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
      
      final response = await _authenticationAPI.register(
        email: _email,
        username: _userName,
        password: _password,
      );
      ProgressDialog.dissmiss(context);
      if (response.data != null) {
        await _authenticationClient.saveSession(response.data!);
        Navigator.pushNamedAndRemoveUntil(
          context,
          RegistrerHome.routeName,
          (_) => false,
        );
      } else {

        String? message = response.error!.message;
        if (response.error!.statusCode==-1) {
          message = "No hay conexión a internet";
        } else {
          var messages = response.error!.data['duplicatedFields'];
          if (messages.length>1) {
            message = "${jsonEncode(messages[0])} y ${jsonEncode(messages[1])} ya existen";
          } else {
            message = "El ${jsonEncode(messages[0])} ya existe";
          }
          
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
          -40, //si no le cargo otros valores da error porque el positioned debe ir dentro de un stack
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
                  label: 'Nombre de Usuario',
                  borderEnabled: false,
                  fontSize: responsive.dp(1.8),
                  onChanged: (text) {
                    _userName = text;
                  },
                  validator: (text) {
                    if (text!.trim().length < 5) {
                      return "No es válido, tiene menos de 5 caracteres";
                    }
                    return null;
                  },
                  fontSizeError: responsive.dp(1.4),
                ),
              ),
              SizedBox(
                height: responsive.dp(2),
              ),
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
              SizedBox(
                height: responsive.dp(2),
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ))),
                child: InputText(
                  obscureText: _obscurePassword,
                  keyboardType: TextInputType.emailAddress,
                  label: 'Password',
                  borderEnabled: false,
                  fontSize: responsive.dp(1.8),
                  onChanged: (text) {
                    _password = text;
                  },
                  validator: (text) {
                    if (text!.trim().length < 6) {
                      return "No valido, tiene menos de 6 caracteres";
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
              SizedBox(
                height: responsive.dp(5),
              ),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: this._submit,
                  child: Text(
                    'Registrar',
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
                    "¿Ya tienes una cuenta?",
                    style: TextStyle(
                        fontSize: responsive.dp(1.6),
                        color: Theme.of(context).textTheme.bodyMedium?.color),
                  ),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Iniciar Sesión',
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

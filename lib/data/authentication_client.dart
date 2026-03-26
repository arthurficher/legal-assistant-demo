import 'dart:async';
import 'dart:convert';

import 'package:flutter_gemini/api/authentication_api.dart';
import 'package:flutter_gemini/models/authentication_response.dart';
import 'package:flutter_gemini/models/session.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthenticationClient {
  final FlutterSecureStorage _secureStorage;
  final AuthenticationAPI _authenticationAPI;
  Completer<void>? _completer;

  AuthenticationClient(this._secureStorage, this._authenticationAPI);

  Future<String?> get accesToken async {
    if (_completer != null) {
      await _completer!.future;
    }

    _completer = Completer<void>();

    try {
      final data = await _secureStorage.read(key: 'SESSION');
      if (data != null) {
        final session = Session.fromJson(jsonDecode(data));

        final DateTime currentDate = DateTime.now();
        final DateTime createdAt = session.createdAt;
        final int expiresIn = session.expiresIn;
        final int diff = currentDate.difference(createdAt).inSeconds;

        print('session life time= ${expiresIn - diff}');

        if (expiresIn - diff >= 60) {
          return session.token;
        }

        final response = await _authenticationAPI.refreshToken(session.token);
        if (response.data != null) {
          await this.saveSession(response.data!);
          return response.data!.token;
        }
        return null;
      }
      return null;
    } finally {
      _completer!.complete();
      _completer = null;
    }
  }

  //para guardar la sesion
  Future<void> saveSession(
      AuthenticationResponse authenticationResponse) async {
    final Session session = Session(
      token: authenticationResponse.token,
      expiresIn: authenticationResponse.expiresIn,
      createdAt: DateTime.now(),
    );

    final data = jsonEncode(session.toJson());
    await _secureStorage.write(key: 'SESSION', value: data);
  }

  //para cerrar sesion
  Future<void> singOut() async {
    await _secureStorage.deleteAll();
  }
}
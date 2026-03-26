import 'package:flutter_gemini/helpers/http.dart';
import 'package:flutter_gemini/helpers/http_response_helpers.dart';
import 'package:flutter_gemini/models/authentication_response.dart';
import 'package:flutter_gemini/constants.dart';

class AuthenticationAPI {
  final Http _http;

  AuthenticationAPI(this._http);

  Future<HttpResponseHelpers<AuthenticationResponse?>> register({
    required String email,
    required String username,
    required String password,
  }) {
    return _http.request<AuthenticationResponse>(
      '/api/v1/register',
      method: "POST",
      data: {
        "username": username,
        "email": email,
        "password": password,
      },
      parser: (data) {
        return AuthenticationResponse.fromJson(data);
      },
    );
  }

  Future<HttpResponseHelpers<AuthenticationResponse?>> login({
    required String email,
    required String password,
  }) async {
    // Usar datos mock si está habilitado
    if (Constants.useMockAuth) {
      // Simular un delay de red
      await Future.delayed(Duration(milliseconds: 500));
      
      // Verificar credenciales mock
      if (email == Constants.mockEmail && password == Constants.mockPassword) {
        // Retornar respuesta exitosa con token mock
        final mockResponse = AuthenticationResponse(
          token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
          expiresIn: 3600, // 1 hora
        );
        return HttpResponseHelpers.success(mockResponse);
      } else {
        // Retornar error de credenciales inválidas
        return HttpResponseHelpers.fail(
          statusCode: 403,
          message: 'Credenciales inválidas. Use: ${Constants.mockEmail} / ${Constants.mockPassword}',
          data: null,
        );
      }
    }
    
    // Usar autenticación real
    return _http.request<AuthenticationResponse>(
      '/api/v1/login',
      method: "POST",
      data: {
        "email": email,
        "password": password,
      },
      parser: (data) {
        return AuthenticationResponse.fromJson(data);
      },
    );
  }

  Future<HttpResponseHelpers<AuthenticationResponse?>> refreshToken(String expireToken) {
    return _http.request<AuthenticationResponse>(
      '/api/v1/refresh-token',
      method: "POST",
      headers: {
        "token": expireToken,
      },
      parser: (data) {
        print('data: $data');
        return AuthenticationResponse.fromJson(data);
      },
    );
  }
}

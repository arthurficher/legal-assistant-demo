import 'package:flutter_gemini/data/authentication_client.dart';
import 'package:flutter_gemini/helpers/http.dart';
import 'package:flutter_gemini/helpers/http_response_helpers.dart';
import 'package:flutter_gemini/models/user.dart';

class AccountApi {
  final Http _http;
  final AuthenticationClient _authenticationClient;

  AccountApi(this._http, this._authenticationClient);

  Future<HttpResponseHelpers<User?>> getUserInfo() async{
    final token = await _authenticationClient.accesToken;
    return _http.request<User>(
      '/api/v1/user-info',  
      method: "GET",
      headers: {
        "token": token!,
      },
      parser: (data){
        return User.fromJson(data);
      },
    );
  }
}

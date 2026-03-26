import 'package:dio/dio.dart';
import 'package:flutter_gemini/api/account_api.dart';
import 'package:flutter_gemini/api/authentication_api.dart';
import 'package:flutter_gemini/data/authentication_client.dart';
import 'package:flutter_gemini/helpers/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

abstract class DependencyInjection {
  static void initialized() {
    final Dio dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:9000'));
    Logger logger = Logger();
    Http http = Http(
      dio: dio,
      logger: logger,
      logsEnabled: true,
    );

    final secureStorage = FlutterSecureStorage();

    final authenticationAPI = AuthenticationAPI(http);
    final authenticationClient = AuthenticationClient(secureStorage, authenticationAPI);
    final accountApi = AccountApi(http, authenticationClient);


    GetIt.instance.registerSingleton<AuthenticationAPI>(authenticationAPI);
    GetIt.instance.registerSingleton<AuthenticationClient>(authenticationClient);
    GetIt.instance.registerSingleton<AccountApi>(accountApi);
  }
}

import 'dart:async';
import 'dart:convert';
import 'package:backend_shelf/src/core/services/bcrypt/bcrypt_service.dart';
import 'package:backend_shelf/src/core/services/database/remote_database.dart';
import 'package:backend_shelf/src/core/services/request_extractor/request_extractor.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf/shelf.dart';

class AuthResource extends Resource {
  @override
  List<Route> get routes => [
        //login
        Route.get('/auth/login', _login),
        //refresh_token
        Route.get('/auth/refresh_token', _refreshToken),
        //check_token
        Route.get('/auth/check_token', _checkToken),
        //update password
        Route.post('/auth/update_password', _checkToken),
      ];

  FutureOr<Response> _login(Request request, Injector injector) async {
    final extractor = injector.get<RequestExtractor>();
    final bcrypt = injector.get<BCryptService>();
    final credential = extractor.getAuthorizationBasic(request);
    final database = injector.get<RemoteDatabase>();
    final result = await database.query(
        'SELECT id, role, password FROM "User" WHERE email = @email;',
        variables: {
          'email': credential.email,
        });
    if (result.isEmpty) {
      return Response.forbidden(
          jsonEncode({'error': 'Usuario nao encontrado'}));
    }
    final userMap = result.map((element) => element['User']).first;
    return Response.ok('');
  }

  FutureOr<Response> _refreshToken() {
    return Response.ok('');
  }

  FutureOr<Response> _checkToken() {
    return Response.ok('');
  }

  FutureOr<Response> _updatePassword() {
    return Response.ok('');
  }
}

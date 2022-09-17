import 'dart:async';
import 'dart:convert';
import 'package:backend_shelf/src/core/services/bcrypt/bcrypt_service.dart';
import 'package:backend_shelf/src/core/services/database/remote_database.dart';
import 'package:backend_shelf/src/core/services/jwt/jwt_service.dart';
import 'package:backend_shelf/src/core/services/request_extractor/request_extractor.dart';
import 'package:backend_shelf/src/features/auth/guard/auth_guard.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf/shelf.dart';

class AuthResource extends Resource {
  @override
  List<Route> get routes => [
        //login
        Route.get('/auth/login', _login),
        //refresh_token
        Route.get('/auth/refresh_token', _refreshToken,
            middlewares: [AuthGuard(isRefreshToken: true)]),
        //check_token
        Route.get('/auth/check_token', _checkToken, middlewares: [AuthGuard()]),
        //update password
        Route.post('/auth/update_password', _updatePassword),
      ];

  FutureOr<Response> _login(Request request, Injector injector) async {
    final extractor = injector.get<RequestExtractor>();
    final bcrypt = injector.get<BCryptService>();
    final jwt = injector.get<JwtService>();
    final credential = extractor.getAuthorizationBasic(request);
    final database = injector.get<RemoteDatabase>();
    final result = await database.query(
        'SELECT id, role, password FROM "User" WHERE email = @email;',
        variables: {
          'email': credential.email,
        });
    if (result.isEmpty) {
      return Response.forbidden(jsonEncode({'error': 'User not found'}));
    }
    final userMap = result.map((element) => element['User']).first;
    if (!bcrypt.checkHash(credential.password, userMap!['password'])) {
      return Response.forbidden(jsonEncode({'error': 'Invalid Password'}));
    }

    final payload = userMap..remove('password');

    return Response.ok(jsonEncode(generateToken(payload, jwt)));
  }

  Map generateToken(Map payload, JwtService jwt) {
    payload['exp'] = _determineExpiration(Duration(minutes: 10));
    final accessToken = jwt.generateToken(payload, 'accessToken');
    payload['exp'] = _determineExpiration(Duration(days: 3));
    final refreshToken = jwt.generateToken(payload, 'refreshToken');
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  FutureOr<Response> _refreshToken(Injector injector, Request request) async {
    final extractor = injector.get<RequestExtractor>();
    final jwt = injector.get<JwtService>();

    final token = extractor.getAuthorizationBearer(request);
    var payload = jwt.getPayload(token);
    final database = injector.get<RemoteDatabase>();
    final result = await database
        .query('SELECT id, role FROM "User" WHERE id =@id;', variables: {
      'id': payload['id'],
    });
    payload = result.map((element) => element['User']).first!;
    return Response.ok(jsonEncode(generateToken(payload, jwt)));
  }

  FutureOr<Response> _checkToken() {
    return Response.ok(jsonEncode({'message': 'ok'}));
  }

  FutureOr<Response> _updatePassword() {
    return Response.ok('');
  }

  int _determineExpiration(Duration duration) {
    final expiresDate = DateTime.now().add(duration);
    final expiresIn =
        Duration(milliseconds: expiresDate.millisecondsSinceEpoch);
    return expiresIn.inSeconds;
  }
}

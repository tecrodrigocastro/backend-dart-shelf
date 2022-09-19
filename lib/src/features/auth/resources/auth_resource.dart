import 'dart:async';
import 'dart:convert';
import 'package:backend_shelf/src/core/services/bcrypt/bcrypt_service.dart';
import 'package:backend_shelf/src/core/services/database/remote_database.dart';
import 'package:backend_shelf/src/core/services/jwt/jwt_service.dart';
import 'package:backend_shelf/src/core/services/request_extractor/request_extractor.dart';
import 'package:backend_shelf/src/features/auth/errors/errors.dart';
import 'package:backend_shelf/src/features/auth/guard/auth_guard.dart';
import 'package:backend_shelf/src/features/auth/repositories/auth_repository.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf/shelf.dart';

class AuthResource extends Resource {
  @override
  List<Route> get routes => [
        //login
        Route.get('/login', _login),
        //refresh_token
        Route.get('/refresh_token', _refreshToken,
            middlewares: [AuthGuard(isRefreshToken: true)]),
        //check_token
        Route.get('/check_token', _checkToken, middlewares: [AuthGuard()]),
        //update password
        Route.put('/update_password', _updatePassword,
            middlewares: [AuthGuard()]),
      ];

  FutureOr<Response> _login(Request request, Injector injector) async {
    final authRepository = injector.get<AuthRepository>();
    final extractor = injector.get<RequestExtractor>();
    final credential = extractor.getAuthorizationBasic(request);
    try {
      final tokenization = await authRepository.login(credential);
      return Response.ok(tokenization.toJson());
    } on AuthException catch (e) {
      return Response(e.statusCode, body: e.toJson());
    }
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

  FutureOr<Response> _updatePassword(
      Injector injector, Request request, ModularArguments arguments) async {
    final extractor = injector.get<RequestExtractor>();
    final jwt = injector.get<JwtService>();
    final database = injector.get<RemoteDatabase>();
    final bcrypt = injector.get<BCryptService>();
    final data = arguments.data as Map;
    final token = extractor.getAuthorizationBearer(request);
    var payload = jwt.getPayload(token);
    final result = await database
        .query('SELECT password FROM "User" WHERE id =@id;', variables: {
      'id': payload['id'],
    });
    final password =
        result.map((element) => element['User']).first!['password'];

    if (!bcrypt.checkHash(data['password'], password)) {
      return Response.forbidden(jsonEncode({'error': 'Senha invalida'}));
    }
    final queryUpdate = 'UPDATE "User" SET password=@password WHERE id=@id;';
    await database.query(queryUpdate, variables: {
      'id': payload['id'],
      'password': bcrypt.generateHash(data['newPassword'])
    });
    return Response.ok(jsonEncode({'message': 'ok'}));
  }

  int _determineExpiration(Duration duration) {
    final expiresDate = DateTime.now().add(duration);
    final expiresIn =
        Duration(milliseconds: expiresDate.millisecondsSinceEpoch);
    return expiresIn.inSeconds;
  }
}

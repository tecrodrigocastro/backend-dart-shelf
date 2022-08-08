// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'package:backend_shelf/src/core/services/dot_env/dot_env_service.dart';
import 'package:backend_shelf/src/core/services/jwt/jwt_service.dart';

class JwtServiceImpl implements JwtService {
  final DotEnvService dotEnvService;
  JwtServiceImpl(this.dotEnvService);
  @override
  String generateToken(Map claims, String audiance) {
    final jwt = JWT(claims, audience: Audience.one(audiance));
    final token = jwt.sign(SecretKey(dotEnvService['JWT_KEY']!));
    return token;
  }

  @override
  Map getPayload(String token) {
    final jwt = JWT.verify(
      token,
      SecretKey(dotEnvService['JWT_KEY']!),
      checkExpiresIn: false,
      checkHeaderType: false,
      checkNotBefore: false,
    );
    return jwt.payload;
  }

  @override
  void verifyToken(String token, String audiance) {
    JWT.verify(
      token,
      SecretKey(dotEnvService['JWT_KEY']!),
      audience: Audience.one(audiance),
    );
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:backend_shelf/src/core/services/bcrypt/bcrypt_service.dart';
import 'package:backend_shelf/src/core/services/database/remote_database.dart';
import 'package:backend_shelf/src/core/services/jwt/jwt_service.dart';
import 'package:backend_shelf/src/features/auth/errors/errors.dart';
import 'package:backend_shelf/src/features/auth/models/tokenization.dart';

import '../../../core/services/request_extractor/request_extractor.dart';

class AuthRepository {
  final BCryptService bcrypt;
  final JwtService jwt;
  final RemoteDatabase database;
  AuthRepository(this.bcrypt, this.jwt, this.database);

  Future<Tokenization> login(LoginCredential credential) async {
    final result = await database.query(
        'SELECT id, role, password FROM "User" WHERE email = @email;',
        variables: {
          'email': credential.email,
        });
    if (result.isEmpty) {
      throw AuthException(403, 'User not found');
    }
    final userMap = result.map((element) => element['User']).first;
    if (!bcrypt.checkHash(credential.password, userMap!['password'])) {
      throw AuthException(403, 'Invalid Password');
    }
    final payload = userMap..remove('password');
    return _generateToken(payload);
  }

  Tokenization _generateToken(Map payload) {
    payload['exp'] = _determineExpiration(Duration(minutes: 10));
    final accessToken = jwt.generateToken(payload, 'accessToken');
    payload['exp'] = _determineExpiration(Duration(days: 3));
    final refreshToken = jwt.generateToken(payload, 'refreshToken');
    return Tokenization(accessToken: accessToken, refreshToken: refreshToken);
  }

  int _determineExpiration(Duration duration) {
    final expiresDate = DateTime.now().add(duration);
    final expiresIn =
        Duration(milliseconds: expiresDate.millisecondsSinceEpoch);
    return expiresIn.inSeconds;
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:backend_shelf/src/core/services/bcrypt/bcrypt_service.dart';
import 'package:backend_shelf/src/core/services/jwt/jwt_service.dart';
import 'package:backend_shelf/src/features/auth/errors/errors.dart';
import 'package:backend_shelf/src/features/auth/models/tokenization.dart';

import '../../../core/services/request_extractor/request_extractor.dart';

abstract class AuthDatasource {
  Future<Map> getIdAndRoleByEmail(String email);
  Future<String> getRoleById(id);
  Future<String> getPasswordById(id);
  Future<void> updatePasswordById(id, String password);
}

class AuthRepository {
  final BCryptService bcrypt;
  final JwtService jwt;
  final AuthDatasource datasource;
  AuthRepository(this.datasource, this.bcrypt, this.jwt);

  Future<Tokenization> login(LoginCredential credential) async {
    final userMap = await datasource.getIdAndRoleByEmail(credential.email);
    if (userMap.isEmpty) {
      throw AuthException(403, 'User not found');
    }
    // final userMap = result.map((element) => element['User']).first;
    if (!bcrypt.checkHash(credential.password, userMap['password'])) {
      throw AuthException(403, 'Invalid Password');
    }
    final payload = userMap..remove('password');
    return _generateToken(payload);
  }

  Future<Tokenization> refreshToken(String token) async {
    final payload = jwt.getPayload(token);
    final role = await datasource.getRoleById(payload['id']);
    return _generateToken({
      'id': payload['id'],
      'role': role,
    });
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

  Future<void> updatePassword(
      token, String password, String newPassword) async {
    final payload = jwt.getPayload(token);
    final hash = await datasource.getPasswordById(payload['id']);

    if (!bcrypt.checkHash(password, hash)) {
      throw AuthException(403, 'senha invalida');
    }
    newPassword = bcrypt.generateHash(newPassword);
    await datasource.updatePasswordById(payload['id'], newPassword);
  }
}

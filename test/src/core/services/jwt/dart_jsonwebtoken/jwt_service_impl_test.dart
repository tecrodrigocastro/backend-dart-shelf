import 'package:backend_shelf/src/core/services/dot_env/dot_env_service.dart';
import 'package:backend_shelf/src/core/services/jwt/dart_jsonwebtoken/jwt_service_impl.dart';
import 'package:backend_shelf/src/core/services/jwt/jwt_service.dart';
import 'package:test/test.dart';

void main() {
  test('jwt create', () async {
    final dotEnvService = DotEnvService(mocks: {
      'JWT_KEY': 'SADScADNLKBAKJDaslmdsadlakdbkalk12',
    });
    final jwt = JwtServiceImpl(dotEnvService);

    final expiresDate = DateTime.now().add(Duration(seconds: 30));
    final expires =
        Duration(milliseconds: expiresDate.millisecondsSinceEpoch).inSeconds;

    final token = jwt.generateToken({
      'id': 1,
      'role': 'user',
      'exp': expires,
    }, 'accessToken');

    print(token);
  });

  test('jwt verify', () {
    final dotEnvService = DotEnvService(mocks: {
      'JWT_KEY': 'SADScADNLKBAKJDaslmdsadlakdbkalk12',
    });
    final jwt = JwtServiceImpl(dotEnvService);
    String token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwicm9sZSI6InVzZXIiLCJleHAiOjE2NTk4MDY4MTQsImlhdCI6MTY1OTgwNjc1NCwiYXVkIjoiYWNjZXNzVG9rZW4ifQ.XYTP7zLnwy6mp_mvbg-UxRu5N-seoeTNHRktfjeZg3c';
    jwt.verifyToken(
      token,
      'accessToken',
    );
  });

  test('jwt payload', () {
    final dotEnvService = DotEnvService(mocks: {
      'JWT_KEY': 'SADScADNLKBAKJDaslmdsadlakdbkalk12',
    });
    final jwt = JwtServiceImpl(dotEnvService);
    String token =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MSwicm9sZSI6InVzZXIiLCJleHAiOjE2NTk4MDY5NDgsImlhdCI6MTY1OTgwNjkxOCwiYXVkIjoiYWNjZXNzVG9rZW4ifQ.ZD9G8LliP-qtEGsXE3oOmZLMJ3qME1kKQccOuNXaqlM';
    final payload = jwt.getPayload(
      token,
    );
    print(payload);
  });
}

import 'package:backend_shelf/src/core/services/database/remote_database.dart';
import 'package:backend_shelf/src/features/auth/repositories/auth_repository.dart';

class AuthDatasourceImpl implements AuthDatasource {
  final RemoteDatabase database;

  AuthDatasourceImpl(this.database);

  @override
  Future<Map> getIdAndRuleByEmail(String email) async {
    final result = await database.query(
        'SELECT id, role, password FROM "User" WHERE email = @email;',
        variables: {
          'email': email,
        });
    if (result.isEmpty) {
      return {};
    }
    return result.map((element) => element['User']).first!;
  }
}

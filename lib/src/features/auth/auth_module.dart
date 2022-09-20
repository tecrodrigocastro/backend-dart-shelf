import 'package:backend_shelf/src/features/auth/datasources/auth_datasource_impl.dart';
import 'package:backend_shelf/src/features/auth/repositories/auth_repository.dart';
import 'package:shelf_modular/shelf_modular.dart';

import 'resources/auth_resource.dart';

class AuthModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.singleton((i) => AuthRepository(i(), i(), i())),
        Bind.singleton<AuthDatasource>((i) => AuthDatasourceImpl(i())),
      ];
  @override
  List<ModularRoute> get routes => [
        Route.resource(AuthResource()),
      ];
}

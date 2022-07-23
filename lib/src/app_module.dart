import 'package:backend_shelf/src/core/services/database/postgres/postgres_database.dart';
import 'package:backend_shelf/src/core/services/database/remote_database.dart';
import 'package:backend_shelf/src/core/services/dot_env/dot_env_service.dart';
import 'package:backend_shelf/src/features/auth/user/user_resource.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf/shelf.dart';

class AppModule extends Module {
  @override
  List<Bind<Object>> get binds => [
        Bind.instance<DotEnvService>(DotEnvService.instance),
        Bind.singleton<RemoteDatabase>((i) => PostgresDatabase(i())),
      ];
  @override
  List<ModularRoute> get routes => [
        Route.get('/', (Request request) => Response.ok('Inicial')),
        Route.resource(UserResource()),
      ];
}

import 'package:backend_shelf/src/core/core_module.dart';
import 'package:backend_shelf/src/core/services/bcrypt/bcrypt_service.dart';
import 'package:backend_shelf/src/core/services/bcrypt/bcrypt_service_imp.dart';
import 'package:backend_shelf/src/core/services/database/postgres/postgres_database.dart';
import 'package:backend_shelf/src/core/services/database/remote_database.dart';
import 'package:backend_shelf/src/core/services/dot_env/dot_env_service.dart';
import 'package:backend_shelf/src/core/services/jwt/dart_jsonwebtoken/jwt_service_impl.dart';
import 'package:backend_shelf/src/core/services/jwt/jwt_service.dart';
import 'package:backend_shelf/src/core/services/request_extractor/request_extractor.dart';
import 'package:backend_shelf/src/features/auth/resources/auth_resource.dart';
import 'package:backend_shelf/src/features/swagger/swagger_handler.dart';
import 'package:backend_shelf/src/features/user/user_resource.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf/shelf.dart';

import 'features/auth/auth_module.dart';

class AppModule extends Module {
  @override
  List<Module> get imports => [CoreModule()];

  @override
  List<ModularRoute> get routes => [
        Route.get('/', (Request request) => Response.ok('Inicial')),
        Route.get('/documentation/**', swaggerHandler),
        Route.resource(UserResource()),
        Route.module('/auth', module: AuthModule())
      ];
}

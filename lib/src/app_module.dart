import 'package:backend_shelf/src/features/auth/user/user_resource.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf/shelf.dart';

class AppModule extends Module {
  @override
  List<ModularRoute> get routes => [
        Route.get('/', (Request request) => Response.ok('Inicial')),
        Route.resource(UserResource()),
      ];
}

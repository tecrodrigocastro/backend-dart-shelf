import 'package:shelf_modular/shelf_modular.dart';

import 'resources/auth_resource.dart';

class AuthModule extends Module {
  @override
  List<ModularRoute> get routes => [
        Route.resource(AuthResource()),
      ];
}

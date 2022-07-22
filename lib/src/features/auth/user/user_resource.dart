import 'dart:async';

import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf/shelf.dart';

class UserResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get('/user', _getAllUser),
        Route.get('/user/:id', _getAllUserById),
        Route.post('/user', _createUser),
        Route.put('/user', _updateUser),
        Route.delete('/user/:id', _deleteUser),
      ];

  FutureOr<Response> _getAllUser() {
    return Response.ok('ok');
  }

  FutureOr<Response> _getAllUserById(ModularArguments arguments) {
    return Response.ok('User: ${arguments.params['id']}');
  }

  FutureOr<Response> _createUser(ModularArguments arguments) {
    return Response.ok('Created User: ${arguments.data}');
  }

  FutureOr<Response> _updateUser(ModularArguments arguments) {
    return Response.ok('Updated User: ${arguments.data}');
  }

  FutureOr<Response> _deleteUser(ModularArguments arguments) {
    return Response.ok('Deleted User: ${arguments.params['id']}');
  }
}

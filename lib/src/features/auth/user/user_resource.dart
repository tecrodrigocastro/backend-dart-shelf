import 'dart:async';
import 'dart:convert';

import 'package:backend_shelf/src/core/services/database/remote_database.dart';
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

  FutureOr<Response> _getAllUser(Injector injector) async {
    final database = injector.get<RemoteDatabase>();

    final result =
        await database.query('SELECT id, name, email, role FROM "User";');
    //final userMap = result.map((element) => element['User']).first;
    final listUsers = result.map((e) => e['User']).toList();
    return Response.ok(jsonEncode(listUsers));
  }

  FutureOr<Response> _getAllUserById(
      ModularArguments arguments, Injector injector) async {
    final id = arguments.params['id'];
    final database = injector.get<RemoteDatabase>();

    final result = await database.query(
        'SELECT id, name, email, role FROM "User" WHERE id = @id;',
        variables: {'id': id});
    final userMap = result.map((element) => element['User']).first;
    return Response.ok(jsonEncode(userMap));
  }

  FutureOr<Response> _createUser(
      ModularArguments arguments, Injector injector) async {
    final userParams = (arguments.data as Map).cast<String, dynamic>();
    userParams.remove('id');
    final database = injector.get<RemoteDatabase>();
    final query = await database.query(
      'INSERT INTO "User" (name, email, password) VALUES (@name, @email, @password) RETURNING id, name, email, role;',
      variables: userParams,
    );
    final userMap = query.map((e) => e['User']).first;
    return Response.ok(jsonEncode(userMap));
  }

  FutureOr<Response> _updateUser(
      ModularArguments arguments, Injector injector) async {
    final userParams = (arguments.data as Map).cast<String, dynamic>();
    //userParams.remove('id');
    final database = injector.get<RemoteDatabase>();
    final query = await database.query(
        'UPDATE "User" SET name=@name, email=@email, password=@password WHERE id=@id RETURNING id, name, email, role',
        variables: userParams);
    return Response.ok('Updated User: ${arguments.data}');
  }

  FutureOr<Response> _deleteUser(
      ModularArguments arguments, Injector injector) async {
    final id = arguments.params['id'];
    final database = injector.get<RemoteDatabase>();
    final result = await database
        .query('DELETE FROM "User" WHERE id = @id;', variables: {'id': id});
    return Response.ok('Deleted User: ${arguments.params['id']}');
  }
}

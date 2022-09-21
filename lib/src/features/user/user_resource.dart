import 'dart:async';
import 'dart:convert';

import 'package:backend_shelf/src/core/services/bcrypt/bcrypt_service.dart';
import 'package:backend_shelf/src/core/services/database/remote_database.dart';
import 'package:backend_shelf/src/features/auth/guard/auth_guard.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf/shelf.dart';

class UserResource extends Resource {
  @override
  List<Route> get routes => [
        Route.get('/user', _getAllUser, middlewares: [AuthGuard()]),
        Route.get('/user/:id', _getAllUserById, middlewares: [AuthGuard()]),
        Route.post('/user', _createUser),
        Route.post('/teste', teste),
        Route.put('/user', _updateUser, middlewares: [AuthGuard()]),
        Route.delete('/user/:id', _deleteUser, middlewares: [
          AuthGuard(roles: ['admin'])
        ]),
      ];

  FutureOr<Response> teste(ModularArguments args) {
    final dados = args.data;
    if (dados.isEmpty) {
      return Response.ok('em branco');
    }
    return Response.ok('New teste added: $dados');
  }

  FutureOr<Response> getUser(ModularArguments args) =>
      Response.ok('user id ${args.params['id']}');

  FutureOr<Response> _getAllUser(Injector injector) async {
    final database = injector.get<RemoteDatabase>();

    final result = await database.query('SELECT * FROM "User";');
    //final userMap = result.map((element) => element['User']).first;
    final listUsers = result.map((e) => e['User']).toList();
    return Response.ok(jsonEncode(listUsers));
  }

  FutureOr<Response> _getAllUserById(
      ModularArguments arguments, Injector injector) async {
    final id = arguments.params['id'];
    final database = injector.get<RemoteDatabase>();

    final result = await database
        .query('SELECT * FROM "User" WHERE id = @id;', variables: {'id': id});
    final userMap = result.map((element) => element['User']).first;
    return Response.ok(jsonEncode(userMap));
  }

  FutureOr<Response> _createUser(
      ModularArguments arguments, Injector injector) async {
    final bcrypt = injector.get<BCryptService>();

    final userParams = (arguments.data as Map).cast<String, dynamic>();

    userParams['password'] = bcrypt.generateHash(userParams['password']);
    //userParams.remove('id');
    final database = injector.get<RemoteDatabase>();
    final query = await database.query(
      'INSERT INTO "User" (name, email, password, gender, age, weigth, heigth, goal) VALUES (@name, @email, @password, @gender, @age, @weigth, @heigth, @goal) RETURNING id, name, email;',
      variables: userParams,
    );
    final userMap = query.map((e) => e['User']).first;
    return Response.ok(jsonEncode(userMap));
  }

  FutureOr<Response> _updateUser(
      ModularArguments arguments, Injector injector) async {
    final userParams = (arguments.data as Map).cast<String, dynamic>();
    //userParams.remove('id');
    final colums = userParams.keys
        .where((key) => key != 'id' || key != 'password')
        .map((key) => '$key=@$key')
        .toList();
    final database = injector.get<RemoteDatabase>();
    final query = await database.query(
        'UPDATE "User" SET ${colums.join(',')} WHERE id=@id RETURNING id, name, email, role',
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

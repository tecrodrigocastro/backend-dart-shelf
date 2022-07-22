import 'package:backend_shelf/src/app_module.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf/shelf.dart';

Future<Handler> startShelfModular() async {
  final handler = Modular(module: AppModule(), middlewares: [
    logRequests(),
  ]);
  return handler;
}

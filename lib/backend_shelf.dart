import 'package:backend_shelf/src/app_module.dart';
import 'package:shelf_modular/shelf_modular.dart';
import 'package:shelf/shelf.dart';

Future<Handler> startShelfModular() async {
  final handler = Modular(module: AppModule(), middlewares: [
    logRequests(),
    jsonResponse(),
  ]);
  return handler;
}

Middleware jsonResponse() {
  return (handler) {
    return (request) async {
      var response = await handler(request);

      response = response.change(headers: {
        "content-type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST, GET, OPTIONS, PUT, DELETE, HEAD",
        "Access-Control-Allow-Headers":
            "Origin,X-Requested-With, Content-Type, Accept",
        ...response.headers,
      });

      return response;
    };
  };
}

import 'package:backend_shelf/backend_shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main(List<String> arguments) async {
  final handler = await startShelfModular();
  final server = await io.serve(handler, '0.0.0.0', 4245);

  print('Server: ${server.address.address} : Port: ${server.port}');
}

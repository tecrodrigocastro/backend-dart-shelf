import 'dart:io';

class DotEnvService {
  final Map<String, String> _map = {};
  static DotEnvService instance = DotEnvService._();

  DotEnvService._() {
    _init();
  }

  void _init() {
    final file = File('.env');
    final envtext = file.readAsStringSync();

    for (var line in envtext.split('\n')) {
      final lineBreak = line.split('=');
      _map[lineBreak[0]] = lineBreak[1];
    }
  }

  String? operator [](String key) {
    return _map[key];
  }
}
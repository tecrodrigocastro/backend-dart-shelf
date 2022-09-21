import 'dart:io';

class DotEnvService {
  final Map<String, String> _map = {};
  //static DotEnvService instance = DotEnvService._();

  DotEnvService({Map<String, String>? mocks}) {
    if (mocks == null) {
      _init();
    } else {
      //print('NAO ENTROU');
      _map.addAll(mocks);
    }
  }

  void _init() {
    //print('DENTRO DO INIT DO ENV');
    final file = File('.env');
    final envtext = file.readAsStringSync();
    // print(envtext);

    for (var line in envtext.split('\n')) {
      // print('ENTROU NO FOR DO .ENV - ${line.length}');
      final lineBreak = line.split('=');
      //print('TAMANHO : ${lineBreak.length}');
      // print('${lineBreak[0]} = ${lineBreak[1]}');
      if (lineBreak.length != 1) {
        _map[lineBreak[0]] = lineBreak[1];
      }
      // print(_map);
    }
  }

  String? operator [](String key) {
    return _map[key]?.trim();
  }
}

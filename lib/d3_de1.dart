import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'dart:io';
import 'package:diacritic/diacritic.dart';

Future<void> main() async {
  final gerador = await TermoGenerator.instance();

  Play jogo = Play(gerador.palavraAleatoria);
  jogo.rodar();
}

class ColorPrint {
  static String black(String text) => '\x1B[30m$text\x1B[0m';

  static String red(String text) => '\x1B[31m$text\x1B[0m';

  static String green(String text) => '\x1B[32m$text\x1B[0m';

  static String yellow(String text) => '\x1B[33m$text\x1B[0m';

  static String blue(String text) => '\x1B[34m$text\x1B[0m';

  static String magenta(String text) => '\x1B[35m$text\x1B[0m';

  static String cyan(String text) => '\x1B[36m$text\x1B[0m';

  static String white(String text) => '\x1B[37m$text\x1B[0m';
}

class TermoGenerator {
  TermoGenerator._();

  static TermoGenerator? _instance;
  final _termos = <String>[];
  final _random = Random();

  static Future<TermoGenerator> instance() async {
    if (_instance == null) {
      TermoGenerator._instance = TermoGenerator._();
      await _instance!._inicializar();
    }
    return _instance!;
  }

  Future<void> _inicializar() async {
    final url =
        "https://raw.githubusercontent.com/LinceTech/dart-workshops/main/dart-desafio-3/de_1/termos.json";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonList = convert.jsonDecode(response.body);
        for (final termo in jsonList['termos']) {
          _termos.add(termo);
        }
      } else {
        throw Exception(
          'Erro na requisicao: [${response.statusCode}] ${response.body}',
        );
      }
    } catch (error, stack) {
      print('Error: $error\n$stack');
    }
  }

  String get palavraAleatoria {
    return _termos[_random.nextInt(_termos.length)];
  }
}

class Play {
  Play(this.palavraFinal);

  int tentativas = 0;
  // Armazena a palavra da requisição
  String palavraFinal;
  bool acertou = false;

  void rodar() {
    print(palavraFinal);
    // Faz o loop do jogo
    while (tentativas < 5 && !acertou) {
      print("Escreva a sua palavra: ");
      // Pega o input do usuário
      String tentativaStr = recebeString();
      // Verifica se as letras estão na palavra final
      verificaPalavra(tentativaStr);
      tentativas++;
      break;
    }
  }

  // Recebe o input do usuário e valida se possuí 5 caracteres
  String recebeString() {
    String? tentativaStr = stdin.readLineSync();
    if (tentativaStr!.length != 5) {
      print("Quantidade de caracteres inválido.");
      // Se não tiver 5 caracteres, pede input novamente
      recebeString();
    }
    return tentativaStr;
  }

  bool verificaPalavra(String palavraTentativa) {
    // Remove acentos das palavras
    palavraFinal = removeDiacritics(palavraFinal.toLowerCase());
    palavraTentativa = removeDiacritics(palavraTentativa.toLowerCase());

    // Armazena a string para ser mostrada com as cores
    final palavraRetorno = <String>[];

    // Separa cada letra da palavra final e do input
    final Map<int, String> palavraFinalSeparada = {};
    for (var i = 0; i < palavraFinal.length; i++) {
      palavraFinalSeparada.addAll({i: palavraFinal[i]});
    }
    print(palavraFinalSeparada.toString());

    // Se a palavra do input for a palavra certa, retornar acertou como true
    if (palavraTentativa == palavraFinal) {
      print("Você acertou!");
      // Adiciona a palavra no terminal na cor verde
      palavraRetorno.add(ColorPrint.green(palavraTentativa));
      print(palavraRetorno.toString());
      return acertou = true;
    }

    // Verifica cada letra para saber se estão no lugar certou ou existem na palavra final
    for (var i = 0; i < palavraFinal.length; i++) {
      if (palavraTentativa[i] == palavraFinal[i]) {
        palavraRetorno.add(ColorPrint.green(palavraTentativa[i]));
      } else {
        if (palavraFinal.contains(palavraTentativa[i]) &&
            palavraTentativa[i] != palavraFinal[i]) {
          palavraRetorno.add(ColorPrint.yellow(palavraTentativa[i]));
        } else {
          palavraRetorno.add(ColorPrint.red(palavraTentativa[i]));
        }
      }
    }

    print("Palavra Retorno: ${palavraRetorno.toString()}");
    rodar();
    return false;
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'livro.dart';

class FalhaApi implements Exception {
  FalhaApi(this.mensagem);

  final String mensagem;

  @override
  String toString() => mensagem;
}

/// Cliente HTTP da API do Acervo.
///
/// Cada método monta a URL, envia o verbo HTTP e converte o JSON
/// em [Livro]. Se a API estiver desligada ou devolver erro, lança [FalhaApi].
class AcervoApi {
  AcervoApi({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      baseUrl = _semBarra(
        baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'http://127.0.0.1:3000',
            ),
      );

  final http.Client _client;
  final String baseUrl;

  static String _semBarra(String url) {
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  Future<List<Livro>> listar({String busca = ''}) async {
    final termo = busca.trim();
    final uri = Uri.parse('$baseUrl/livros').replace(
      queryParameters: termo.isEmpty ? null : {'busca': termo},
    );
    final resposta = await _enviar(() => _client.get(uri));
    final lista = jsonDecode(resposta.body) as List<dynamic>;
    return lista
        .map((item) => Livro.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Livro> criar({
    required String titulo,
    required String autor,
    required int ano,
  }) async {
    final resposta = await _enviar(
      () => _client.post(
        Uri.parse('$baseUrl/livros'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'titulo': titulo,
          'autor': autor,
          'ano': ano,
        }),
      ),
    );
    return Livro.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  Future<Livro> atualizar(Livro livro) async {
    final resposta = await _enviar(
      () => _client.put(
        Uri.parse('$baseUrl/livros/${livro.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(livro.toJson()),
      ),
    );
    return Livro.fromJson(jsonDecode(resposta.body) as Map<String, dynamic>);
  }

  Future<void> remover(String id) async {
    await _enviar(() => _client.delete(Uri.parse('$baseUrl/livros/$id')));
  }

  Future<http.Response> _enviar(Future<http.Response> Function() pedido) async {
    final http.Response resposta;
    try {
      resposta = await pedido().timeout(const Duration(seconds: 8));
    } on TimeoutException {
      throw FalhaApi('A API demorou para responder. Tente de novo.');
    } catch (erro) {
      if (erro is FalhaApi) {
        rethrow;
      }
      throw FalhaApi(
        'Não foi possível falar com a API. Confira se ela está em execução em $baseUrl.',
      );
    }

    if (resposta.statusCode >= 400) {
      throw FalhaApi(_mensagem(resposta));
    }
    return resposta;
  }

  String _mensagem(http.Response resposta) {
    try {
      final corpo = jsonDecode(resposta.body);
      if (corpo is Map && corpo['erro'] is String) {
        return corpo['erro'] as String;
      }
    } catch (_) {
      // Corpo vazio ou fora do formato JSON.
    }
    return 'A API respondeu com o código ${resposta.statusCode}.';
  }
}

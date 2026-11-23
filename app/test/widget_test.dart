import 'package:acervo/acervo_api.dart';
import 'package:acervo/livro.dart';
import 'package:acervo/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra os livros devolvidos pela API', (tester) async {
    await tester.pumpWidget(AcervoApp(api: _ApiComLivro()));
    await tester.pumpAndSettle();

    expect(find.text('Dom Casmurro'), findsOneWidget);
    expect(find.text('Disponível'), findsOneWidget);
  });

  testWidgets('mostra erro quando a API não responde', (tester) async {
    await tester.pumpWidget(AcervoApp(api: _ApiIndisponivel()));
    await tester.pumpAndSettle();

    expect(find.textContaining('Não foi possível falar com a API'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });
}

class _ApiComLivro extends AcervoApi {
  @override
  Future<List<Livro>> listar({String busca = ''}) async {
    return const [
      Livro(
        id: '1',
        titulo: 'Dom Casmurro',
        autor: 'Machado de Assis',
        ano: 1899,
        situacao: 'disponivel',
      ),
    ];
  }
}

class _ApiIndisponivel extends AcervoApi {
  @override
  Future<List<Livro>> listar({String busca = ''}) async {
    throw FalhaApi(
      'Não foi possível falar com a API. Confira se ela está em execução.',
    );
  }
}

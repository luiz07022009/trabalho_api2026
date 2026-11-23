import 'package:material_ui/material_ui.dart';

import 'acervo_api.dart';
import 'livro.dart';
import 'pagina_livro.dart';

class PaginaAcervo extends StatefulWidget {
  const PaginaAcervo({super.key, required this.api});

  final AcervoApi api;

  @override
  State<PaginaAcervo> createState() => _PaginaAcervoState();
}

class _PaginaAcervoState extends State<PaginaAcervo> {
  final _busca = TextEditingController();
  late Future<List<Livro>> _carga;

  @override
  void initState() {
    super.initState();
    _carga = widget.api.listar();
  }

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  void _recarregar() {
    setState(() {
      _carga = widget.api.listar(busca: _busca.text);
    });
  }

  Future<void> _abrirFormulario([Livro? livro]) async {
    final mudou = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => PaginaLivro(api: widget.api, livro: livro),
      ),
    );
    if (mudou == true) {
      _recarregar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acervo'),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _recarregar,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Novo livro'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Text(
                  'Biblioteca da turma. A lista vem de GET ${widget.api.baseUrl}/livros.',
                  style: tema.textTheme.bodyMedium,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: TextField(
                  controller: _busca,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _recarregar(),
                  decoration: InputDecoration(
                    hintText: 'Buscar por título ou autor',
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: 'Buscar',
                      onPressed: _recarregar,
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Livro>>(
                  future: _carga,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      final erro = snapshot.error;
                      final mensagem = erro is FalhaApi
                          ? erro.mensagem
                          : 'Não foi possível carregar os livros.';
                      return _EstadoErro(
                        mensagem: mensagem,
                        aoTentar: _recarregar,
                      );
                    }

                    final livros = snapshot.data ?? const <Livro>[];
                    if (livros.isEmpty) {
                      return const _EstadoVazio();
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
                      itemCount: livros.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final livro = livros[index];
                        return _CartaoLivro(
                          livro: livro,
                          aoAbrir: () => _abrirFormulario(livro),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartaoLivro extends StatelessWidget {
  const _CartaoLivro({required this.livro, required this.aoAbrir});

  final Livro livro;
  final VoidCallback aoAbrir;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cor = livro.emprestado
        ? const Color(0xFF8A5A12)
        : const Color(0xFF2F6B4F);

    return Material(
      color: const Color(0xFFFFFDF8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE4D8C8)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: aoAbrir,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFF8C3A2F),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(livro.titulo, style: tema.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text('${livro.autor} · ${livro.ano}'),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                livro.situacaoLegivel,
                style: tema.textTheme.labelLarge?.copyWith(color: cor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text('Nenhum livro encontrado.'),
      ),
    );
  }
}

class _EstadoErro extends StatelessWidget {
  const _EstadoErro({required this.mensagem, required this.aoTentar});

  final String mensagem;
  final VoidCallback aoTentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 42),
            const SizedBox(height: 16),
            Text(mensagem, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: aoTentar, child: const Text('Tentar de novo')),
          ],
        ),
      ),
    );
  }
}

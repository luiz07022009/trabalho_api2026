import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'acervo_api.dart';
import 'capa_livro.dart';
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
  Timer? _atrasoBusca;
  String _filtro = 'todos';

  @override
  void initState() {
    super.initState();
    _carga = widget.api.listar();
  }

  @override
  void dispose() {
    _atrasoBusca?.cancel();
    _busca.dispose();
    super.dispose();
  }

  void _recarregar() {
    setState(() {
      _carga = widget.api.listar(busca: _busca.text);
    });
  }

  void _buscarAoDigitar(String _) {
    setState(() {});
    _atrasoBusca?.cancel();
    _atrasoBusca = Timer(const Duration(milliseconds: 300), _recarregar);
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

  List<Livro> _visiveis(List<Livro> livros) {
    if (_filtro == 'todos') {
      return livros;
    }
    return livros.where((livro) => livro.situacao == _filtro).toList();
  }

  @override
  Widget build(BuildContext context) {
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
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                child: TextField(
                  controller: _busca,
                  textInputAction: TextInputAction.search,
                  onChanged: _buscarAoDigitar,
                  onSubmitted: (_) => _recarregar(),
                  decoration: InputDecoration(
                    hintText: 'Buscar por título ou autor',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _busca.text.isEmpty
                        ? IconButton(
                            tooltip: 'Buscar',
                            onPressed: _recarregar,
                            icon: const Icon(Icons.arrow_forward),
                          )
                        : IconButton(
                            tooltip: 'Limpar busca',
                            onPressed: () {
                              _busca.clear();
                              _recarregar();
                            },
                            icon: const Icon(Icons.close),
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
                    final visiveis = _visiveis(livros);
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 96),
                      children: [
                        _PainelEstante(livros: livros),
                        const SizedBox(height: 16),
                        _Filtros(
                          filtro: _filtro,
                          aoEscolher: (valor) {
                            setState(() => _filtro = valor);
                          },
                        ),
                        const SizedBox(height: 16),
                        if (visiveis.isEmpty)
                          _EstadoVazio(
                            buscaAtiva: _busca.text.trim().isNotEmpty,
                            filtroAtivo: _filtro != 'todos',
                          )
                        else
                          ...[
                            for (var i = 0; i < visiveis.length; i++) ...[
                              if (i > 0) const SizedBox(height: 12),
                              _CartaoLivro(
                                livro: visiveis[i],
                                aoAbrir: () => _abrirFormulario(visiveis[i]),
                              ),
                            ],
                          ],
                      ],
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

class _PainelEstante extends StatelessWidget {
  const _PainelEstante({required this.livros});

  final List<Livro> livros;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final disponiveis = livros.where((livro) => !livro.emprestado).length;
    final emprestados = livros.length - disponiveis;
    final amostra = livros.take(12).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A211C),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BIBLIOTECA',
            style: tema.textTheme.labelSmall?.copyWith(
              color: const Color(0xFFD7C4A8),
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Estante da casa',
            style: tema.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFFF6F1E7),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Cada lombada é um livro do acervo. Toque no cartão para emprestar, devolver ou editar a ficha.',
            style: tema.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFFD7C4A8),
            ),
          ),
          const SizedBox(height: 16),
          if (amostra.isEmpty)
            const Text(
              'A prateleira ainda está vazia.',
              style: TextStyle(color: Color(0xFFD7C4A8)),
            )
          else
            SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: amostra.length,
                separatorBuilder: (context, index) => const SizedBox(width: 6),
                itemBuilder: (context, index) =>
                    LombadaMini(livro: amostra[index]),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Metrica(valor: livros.length, rotulo: 'No acervo', icone: Icons.menu_book),
              const SizedBox(width: 8),
              _Metrica(
                valor: disponiveis,
                rotulo: 'Disponíveis',
                icone: Icons.check_circle_outline,
              ),
              const SizedBox(width: 8),
              _Metrica(
                valor: emprestados,
                rotulo: 'Emprestados',
                icone: Icons.schedule,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({
    required this.valor,
    required this.rotulo,
    required this.icone,
  });

  final int valor;
  final String rotulo;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF3A2E28),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icone, size: 16, color: const Color(0xFFE7C9A4)),
            const SizedBox(height: 8),
            Text(
              '$valor',
              style: const TextStyle(
                color: Color(0xFFF6F1E7),
                fontFamily: 'Georgia',
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              rotulo,
              style: const TextStyle(color: Color(0xFFD7C4A8), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Filtros extends StatelessWidget {
  const _Filtros({required this.filtro, required this.aoEscolher});

  final String filtro;
  final ValueChanged<String> aoEscolher;

  @override
  Widget build(BuildContext context) {
    const opcoes = [
      ('todos', 'Todos'),
      ('disponivel', 'Disponíveis'),
      ('emprestado', 'Emprestados'),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final opcao in opcoes)
          ChoiceChip(
            label: Text(opcao.$2),
            selected: filtro == opcao.$1,
            showCheckmark: false,
            onSelected: (_) => aoEscolher(opcao.$1),
            labelStyle: TextStyle(
              color: filtro == opcao.$1 ? Colors.white : const Color(0xFF1F1A17),
            ),
          ),
      ],
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
    final emprestado = livro.emprestado;
    final cor = emprestado ? const Color(0xFF8A5A12) : const Color(0xFF2F6B4F);

    return Material(
      color: const Color(0xFFFFFDF8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE4D8C8)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: aoAbrir,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CapaLivro(titulo: livro.titulo),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(livro.titulo, style: tema.textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(livro.autor),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Etiqueta(
                          texto: '${livro.ano}',
                          cor: const Color(0xFF5C5148),
                          fundo: const Color(0xFFF3E6D4),
                        ),
                        _Etiqueta(
                          texto: livro.situacaoLegivel,
                          cor: cor,
                          fundo: cor.withValues(alpha: 0.12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF8A7B6E)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({
    required this.texto,
    required this.cor,
    required this.fundo,
  });

  final String texto;
  final Color cor;
  final Color fundo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fundo,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: cor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio({required this.buscaAtiva, required this.filtroAtivo});

  final bool buscaAtiva;
  final bool filtroAtivo;

  @override
  Widget build(BuildContext context) {
    final mensagem = buscaAtiva
        ? 'Nenhum livro corresponde à busca. Tente outro título ou autor.'
        : filtroAtivo
        ? 'Nenhum livro nesta situação. Escolha outro filtro.'
        : 'O acervo ainda está vazio. Cadastre o primeiro livro.';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          const _PrateleiraVazia(),
          const SizedBox(height: 16),
          Text(mensagem, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _PrateleiraVazia extends StatelessWidget {
  const _PrateleiraVazia();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CapaLivro(titulo: 'A', largura: 36, altura: 52),
        SizedBox(width: 8),
        CapaLivro(titulo: 'B', largura: 36, altura: 60),
        SizedBox(width: 8),
        CapaLivro(titulo: 'C', largura: 36, altura: 48),
      ],
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

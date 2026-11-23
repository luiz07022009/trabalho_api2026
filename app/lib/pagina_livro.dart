import 'package:material_ui/material_ui.dart';

import 'acervo_api.dart';
import 'livro.dart';

class PaginaLivro extends StatefulWidget {
  const PaginaLivro({super.key, required this.api, this.livro});

  final AcervoApi api;
  final Livro? livro;

  bool get editando => livro != null;

  @override
  State<PaginaLivro> createState() => _PaginaLivroState();
}

class _PaginaLivroState extends State<PaginaLivro> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _titulo;
  late final TextEditingController _autor;
  late final TextEditingController _ano;
  late String _situacao;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    final livro = widget.livro;
    _titulo = TextEditingController(text: livro?.titulo ?? '');
    _autor = TextEditingController(text: livro?.autor ?? '');
    _ano = TextEditingController(text: livro == null ? '' : '${livro.ano}');
    _situacao = livro?.situacao ?? 'disponivel';
  }

  @override
  void dispose() {
    _titulo.dispose();
    _autor.dispose();
    _ano.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formulario.currentState!.validate()) {
      return;
    }

    setState(() => _salvando = true);
    try {
      if (widget.editando) {
        await widget.api.atualizar(
          widget.livro!.copyWith(
            titulo: _titulo.text.trim(),
            autor: _autor.text.trim(),
            ano: int.parse(_ano.text.trim()),
            situacao: _situacao,
          ),
        );
      } else {
        await widget.api.criar(
          titulo: _titulo.text.trim(),
          autor: _autor.text.trim(),
          ano: int.parse(_ano.text.trim()),
        );
      }
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on FalhaApi catch (falha) {
      _avisar(falha.mensagem);
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  Future<void> _remover() async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover livro'),
          content: Text('Remover "${widget.livro!.titulo}" do acervo?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );
    if (confirmou != true) {
      return;
    }

    setState(() => _salvando = true);
    try {
      await widget.api.remover(widget.livro!.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    } on FalhaApi catch (falha) {
      _avisar(falha.mensagem);
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  void _avisar(String mensagem) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editando ? 'Editar livro' : 'Novo livro'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Form(
            key: _formulario,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              children: [
                TextFormField(
                  controller: _titulo,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe o título.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _autor,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Autor',
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'Informe o autor.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _ano,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Ano',
                    border: OutlineInputBorder(),
                  ),
                  validator: (valor) {
                    final ano = int.tryParse(valor?.trim() ?? '');
                    if (ano == null || ano < 1 || ano > 2100) {
                      return 'Informe um ano entre 1 e 2100.';
                    }
                    return null;
                  },
                ),
                if (widget.editando) ...[
                  const SizedBox(height: 20),
                  Text(
                    'Situação',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'disponivel',
                        label: Text('Disponível'),
                      ),
                      ButtonSegment(
                        value: 'emprestado',
                        label: Text('Emprestado'),
                      ),
                    ],
                    selected: {_situacao},
                    onSelectionChanged: _salvando
                        ? null
                        : (selecao) {
                            setState(() => _situacao = selecao.first);
                          },
                  ),
                ],
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: _salvando ? null : _salvar,
                  child: Text(_salvando ? 'Salvando...' : 'Salvar'),
                ),
                if (widget.editando) ...[
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _salvando ? null : _remover,
                    child: const Text('Remover do acervo'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

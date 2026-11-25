import 'package:material_ui/material_ui.dart';

import 'livro.dart';

const capas = <Color>[
  Color(0xFF8C3A2F),
  Color(0xFF1E4D5C),
  Color(0xFF3E4C32),
  Color(0xFF6A3A4C),
  Color(0xFF2C3D55),
  Color(0xFF7A4B2A),
  Color(0xFF3F4A3A),
  Color(0xFF4C3E6B),
  Color(0xFF5C3A2E),
  Color(0xFF1F4F45),
];

Color corDaCapa(String titulo) {
  var soma = 0;
  for (final unidade in titulo.codeUnits) {
    soma += unidade;
  }
  return capas[soma % capas.length];
}

class CapaLivro extends StatelessWidget {
  const CapaLivro({
    super.key,
    required this.titulo,
    this.largura = 54,
    this.altura = 74,
  });

  final String titulo;
  final double largura;
  final double altura;

  @override
  Widget build(BuildContext context) {
    final cor = corDaCapa(titulo.trim().isEmpty ? 'Livro' : titulo);
    final letra = titulo.trim().isEmpty ? '?' : titulo.trim()[0].toUpperCase();

    return SizedBox(
      width: largura,
      height: altura,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 8,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(width: largura * 0.12, color: const Color(0x33FFFFFF)),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    letra,
                    style: TextStyle(
                      color: const Color(0xFFF6F1E7),
                      fontFamily: 'Georgia',
                      fontSize: altura * 0.34,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: largura * 0.42,
                    height: 2,
                    color: const Color(0x66F6F1E7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LombadaMini extends StatelessWidget {
  const LombadaMini({super.key, required this.livro});

  final Livro livro;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: livro.titulo,
      child: Container(
        width: 16,
        height: 52,
        decoration: BoxDecoration(
          color: corDaCapa(livro.titulo),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: const Color(0x33FFFFFF)),
        ),
      ),
    );
  }
}

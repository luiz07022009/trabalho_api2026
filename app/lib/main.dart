import 'package:material_ui/material_ui.dart';

import 'acervo_api.dart';
import 'pagina_acervo.dart';

void main() {
  runApp(const AcervoApp());
}

class AcervoApp extends StatelessWidget {
  const AcervoApp({super.key, this.api});

  final AcervoApi? api;

  @override
  Widget build(BuildContext context) {
    const tinta = Color(0xFF1F1A17);
    const papel = Color(0xFFF6F1E7);
    const lombada = Color(0xFF8C3A2F);

    return MaterialApp(
      title: 'Acervo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: lombada,
          surface: papel,
        ),
        scaffoldBackgroundColor: papel,
        appBarTheme: const AppBarTheme(
          backgroundColor: papel,
          foregroundColor: tinta,
          elevation: 0,
          centerTitle: false,
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w700,
            color: tinta,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w600,
            color: tinta,
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: lombada,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ),
      home: PaginaAcervo(api: api ?? AcervoApi()),
    );
  }
}

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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFDF8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE4D8C8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFE4D8C8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: lombada, width: 1.6),
          ),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: const Color(0xFFFFFDF8),
          selectedColor: lombada,
          labelStyle: const TextStyle(color: tinta),
          secondaryLabelStyle: const TextStyle(color: Colors.white),
          side: const BorderSide(color: Color(0xFFE4D8C8)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: lombada,
          foregroundColor: Colors.white,
        ),
      ),
      home: PaginaAcervo(api: api ?? AcervoApi()),
    );
  }
}

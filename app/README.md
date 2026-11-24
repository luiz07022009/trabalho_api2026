# Acervo — aplicativo Flutter

Aplicativo para consultar e manter o catálogo de livros servido pela API deste repositório.

## Executar

Requer Flutter com Dart 3.12.0 ou superior.

1. Inicie a API na pasta `../api` com `npm start`.
2. Na pasta `app`, execute `flutter pub get`.
3. Inicie no navegador com `flutter run -d chrome`.

Por padrão, o aplicativo acessa `http://127.0.0.1:3000`. Para configurar outro endereço, use:

```sh
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

No emulador Android, use `http://10.0.2.2:3000` para acessar a API executada na máquina.

## Funcionalidades

- Lista os livros e permite buscar por título ou autor enquanto você digita.
- Cadastra livros com título, autor e ano.
- Edita os dados e a situação de empréstimo de um livro.
- Remove livros com confirmação.
- Mostra estados vazios, erros de conexão e uma ação para tentar carregar novamente.

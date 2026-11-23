# Acervo

API REST e aplicativo Flutter para cadastrar os livros de uma biblioteca. A API guarda os dados em `api/data/livros.json`. O aplicativo consome esses endpoints.

## API

Na pasta `api`:

```sh
npm install
npm start
```

A API sobe em `http://127.0.0.1:3000`.

| Método | Caminho | Função |
| --- | --- | --- |
| GET | `/health` | Confere se a API está no ar |
| GET | `/livros` | Lista os livros. `?busca=` filtra por título ou autor |
| GET | `/livros/:id` | Retorna um livro |
| POST | `/livros` | Cadastra um livro |
| PUT | `/livros/:id` | Atualiza título, autor, ano ou situação |
| DELETE | `/livros/:id` | Remove um livro |

Exemplo de cadastro:

```sh
curl -X POST http://127.0.0.1:3000/livros -H "Content-Type: application/json" -d "{\"titulo\":\"Vidas Secas\",\"autor\":\"Graciliano Ramos\",\"ano\":1938}"
```

Situação aceita `disponivel` ou `emprestado`. Título vazio, ano inválido ou livro inexistente devolvem erro em JSON (`400` ou `404`).

## Aplicativo

Na pasta `app`, com a API já em execução:

```sh
flutter pub get
flutter run -d chrome
```

O endereço padrão é `http://127.0.0.1:3000`. Para outro host:

```sh
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

No emulador Android use `http://10.0.2.2:3000`.

Se a API estiver desligada, a lista mostra o erro e o botão para tentar de novo.

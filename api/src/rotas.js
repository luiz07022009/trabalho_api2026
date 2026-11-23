const express = require("express");
const store = require("./store");
const { validarLivro } = require("./validacao");

const rotas = express.Router();

rotas.get("/health", (_req, res) => {
  res.json({ status: "ok", servico: "acervo-api" });
});

rotas.get("/livros", (req, res) => {
  const termo = String(req.query.busca || "").trim().toLowerCase();
  let livros = store.listar();

  if (termo) {
    livros = livros.filter((livro) => {
      const titulo = livro.titulo.toLowerCase();
      const autor = livro.autor.toLowerCase();
      return titulo.includes(termo) || autor.includes(termo);
    });
  }

  res.json(livros);
});

rotas.get("/livros/:id", (req, res) => {
  const livro = store.buscarPorId(req.params.id);
  if (!livro) {
    return res.status(404).json({ erro: "Livro não encontrado." });
  }
  return res.json(livro);
});

rotas.post("/livros", (req, res) => {
  const resultado = validarLivro(req.body || {});
  if (!resultado.ok) {
    return res.status(400).json({ erro: resultado.erros.join(" ") });
  }

  const livro = store.criar(resultado.dados);
  return res.status(201).json(livro);
});

rotas.put("/livros/:id", (req, res) => {
  if (!store.buscarPorId(req.params.id)) {
    return res.status(404).json({ erro: "Livro não encontrado." });
  }

  const resultado = validarLivro(req.body || {}, { parcial: true });
  if (!resultado.ok) {
    return res.status(400).json({ erro: resultado.erros.join(" ") });
  }

  const livro = store.atualizar(req.params.id, resultado.dados);
  return res.json(livro);
});

rotas.delete("/livros/:id", (req, res) => {
  const removeu = store.remover(req.params.id);
  if (!removeu) {
    return res.status(404).json({ erro: "Livro não encontrado." });
  }
  return res.status(204).send();
});

module.exports = rotas;

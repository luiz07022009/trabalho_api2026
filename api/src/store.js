const fs = require("fs");
const path = require("path");

const arquivo = path.join(__dirname, "..", "data", "livros.json");

function ler() {
  const texto = fs.readFileSync(arquivo, "utf8");
  return JSON.parse(texto);
}

function gravar(livros) {
  fs.writeFileSync(arquivo, JSON.stringify(livros, null, 2) + "\n", "utf8");
}

function listar() {
  return ler();
}

function buscarPorId(id) {
  return ler().find((livro) => livro.id === id) || null;
}

function criar(dados) {
  const livros = ler();
  const livro = {
    id: String(Date.now()),
    titulo: dados.titulo,
    autor: dados.autor,
    ano: dados.ano,
    situacao: dados.situacao || "disponivel",
  };
  livros.push(livro);
  gravar(livros);
  return livro;
}

function atualizar(id, dados) {
  const livros = ler();
  const indice = livros.findIndex((livro) => livro.id === id);
  if (indice === -1) {
    return null;
  }

  const atual = livros[indice];
  const livro = {
    ...atual,
    titulo: dados.titulo ?? atual.titulo,
    autor: dados.autor ?? atual.autor,
    ano: dados.ano ?? atual.ano,
    situacao: dados.situacao ?? atual.situacao,
  };
  livros[indice] = livro;
  gravar(livros);
  return livro;
}

function remover(id) {
  const livros = ler();
  const restante = livros.filter((livro) => livro.id !== id);
  if (restante.length === livros.length) {
    return false;
  }
  gravar(restante);
  return true;
}

module.exports = { listar, buscarPorId, criar, atualizar, remover };

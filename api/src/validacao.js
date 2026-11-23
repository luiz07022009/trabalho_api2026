const situacoes = new Set(["disponivel", "emprestado"]);

function textoObrigatorio(valor, campo) {
  if (typeof valor !== "string" || valor.trim() === "") {
    return `${campo} é obrigatório.`;
  }
  return null;
}

function validarLivro(corpo, { parcial = false } = {}) {
  const erros = [];
  const titulo = corpo.titulo;
  const autor = corpo.autor;
  const ano = corpo.ano;
  const situacao = corpo.situacao;

  if (!parcial || titulo !== undefined) {
    const erro = textoObrigatorio(titulo, "Título");
    if (erro) erros.push(erro);
  }

  if (!parcial || autor !== undefined) {
    const erro = textoObrigatorio(autor, "Autor");
    if (erro) erros.push(erro);
  }

  if (!parcial || ano !== undefined) {
    const numero = Number(ano);
    if (!Number.isInteger(numero) || numero < 1 || numero > 2100) {
      erros.push("Ano precisa ser um número inteiro entre 1 e 2100.");
    }
  }

  if (situacao !== undefined && !situacoes.has(situacao)) {
    erros.push("Situação deve ser disponivel ou emprestado.");
  }

  if (erros.length > 0) {
    return { ok: false, erros };
  }

  return {
    ok: true,
    dados: {
      titulo: typeof titulo === "string" ? titulo.trim() : undefined,
      autor: typeof autor === "string" ? autor.trim() : undefined,
      ano: ano === undefined ? undefined : Number(ano),
      situacao,
    },
  };
}

module.exports = { validarLivro };

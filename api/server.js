const express = require("express");
const cors = require("cors");
const rotas = require("./src/rotas");

const porta = Number(process.env.PORT) || 3000;
const app = express();

app.use(cors());
app.use(express.json());
app.use(rotas);

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ erro: "Falha interna ao processar a requisição." });
});

app.listen(porta, "0.0.0.0", () => {
  console.log(`Acervo API em http://127.0.0.1:${porta}`);
});

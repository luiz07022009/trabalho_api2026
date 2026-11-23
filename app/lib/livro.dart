class Livro {
  const Livro({
    required this.id,
    required this.titulo,
    required this.autor,
    required this.ano,
    required this.situacao,
  });

  final String id;
  final String titulo;
  final String autor;
  final int ano;
  final String situacao;

  bool get emprestado => situacao == 'emprestado';

  String get situacaoLegivel => emprestado ? 'Emprestado' : 'Disponível';

  factory Livro.fromJson(Map<String, dynamic> json) {
    return Livro(
      id: json['id'].toString(),
      titulo: json['titulo'] as String,
      autor: json['autor'] as String,
      ano: (json['ano'] as num).toInt(),
      situacao: json['situacao'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'autor': autor,
      'ano': ano,
      'situacao': situacao,
    };
  }

  Livro copyWith({
    String? titulo,
    String? autor,
    int? ano,
    String? situacao,
  }) {
    return Livro(
      id: id,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      ano: ano ?? this.ano,
      situacao: situacao ?? this.situacao,
    );
  }
}

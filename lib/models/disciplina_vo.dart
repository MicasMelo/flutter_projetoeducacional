import 'package:tarefa2/enums/curso_enum.dart';
import 'package:tarefa2/enums/modalidade_enum.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class DisciplinaVo {
  final String id;
  final String nome;
  final CursoEnum curso;
  final ModalidadeEnum modalidade;
  final DateTime dataCriacao;
  final bool ativo;

  DisciplinaVo({
    required this.nome,
    required this.curso,
    required this.modalidade,
    required this.dataCriacao,
    required this.ativo,
    String? id,
  }) : id = id ?? uuid.v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'curso': curso.index,
      'modalidade': modalidade.index,
      'dataCriacao': dataCriacao.toIso8601String(),
      'ativo': ativo,
    };
  }

  factory DisciplinaVo.fromMap(Map<String, dynamic> map) {
    return DisciplinaVo(
      id: map['id'],
      nome: map['nome'],
      curso: CursoEnum.values[map['curso']],
      modalidade: ModalidadeEnum.values[map['modalidade']],
      dataCriacao: DateTime.parse(map['dataCriacao']),
      ativo: map['ativo'],
    );
  }
}
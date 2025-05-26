import 'package:tarefa2/enums/curso_enum.dart';
import 'package:tarefa2/enums/sexo_enum.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class ProfessorVo {
  final String id;
  final String cpf;
  final String nomeCompleto;
  final String email;
  final DateTime dataNascimento;
  final SexoEnum sexo;
  final CursoEnum curso;
  final bool ativo;

  ProfessorVo({
    required this.cpf,
    required this.nomeCompleto,
    required this.email,
    required this.dataNascimento,
    required this.sexo,
    required this.curso,
    required this.ativo,
    String? id,
  }) : id = id ?? uuid.v4();

  int get idade {
    final now = DateTime.now();
    int idade = now.year - dataNascimento.year;
    if (now.month < dataNascimento.month ||
        (now.month == dataNascimento.month && now.day < dataNascimento.day)) {
      idade--;
    }
    return idade;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'cpf': cpf,
      'nomeCompleto': nomeCompleto,
      'email': email,
      'dataNascimento': dataNascimento.toIso8601String(),
      'sexo': sexo.index,
      'curso': curso.index,
      'ativo': ativo,
    };
  }

  factory ProfessorVo.fromMap(Map<String, dynamic> map) {
    return ProfessorVo(
      id: map['id'],
      cpf: map['cpf'],
      nomeCompleto: map['nomeCompleto'],
      email: map['email'],
      dataNascimento: DateTime.parse(map['dataNascimento']), // aquele ISO
      sexo: SexoEnum.values[map['sexo']],
      curso: CursoEnum.values[map['curso']],
      ativo: map['ativo'],
    );
  }
}
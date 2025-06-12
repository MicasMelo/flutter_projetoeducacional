import 'package:tarefa2/enums/curso_enum.dart';
import 'package:tarefa2/enums/sexo_enum.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class AlunoVo {
  final String id; // uuid
  final String ra;
  final String nomeCompleto;
  final String email;
  final DateTime dataNascimento;
  final SexoEnum sexo;
  final CursoEnum curso;
  final bool matriculado;

  // {} = permite que parâmetros sejam informados por nome
  // required = torna um parâmetro obrigatório
  // AlunoVO(ra: '123', nomeCompleto: 'Micaella' ...);

  AlunoVo({
    required this.ra,
    required this.nomeCompleto,
    required this.email,
    required this.dataNascimento,
    required this.sexo,
    required this.curso,
    required this.matriculado,
    String? id,
  }) : id = id ?? uuid.v4(); // ulid = MongoDB ObjectId

  int get idade {
    final now = DateTime.now();
    int idade = now.year - dataNascimento.year;
    if (now.month < dataNascimento.month ||
        (now.month == dataNascimento.month && now.day < dataNascimento.day)) {
      idade--;
    }
    return idade;
  }

  // Map é um mapa = estrutura de dados baseada em chave (key) e valor (value)
  // dynamic é por ter outros tipos de atributos além de string, assim contempla geral no mapa

  // E é isso aqui que vai mandar para o banco de dados

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ra': ra,
      'nomeCompleto': nomeCompleto,
      'email': email,
      'dataNascimento': dataNascimento.toIso8601String(),
      'sexo': sexo.index,
      'curso': curso.index,
      'matriculado': matriculado,
    };
  }

  // Método factory para pegar do banco de dados e trazer para cá
  // funciona como construtor (de objetos, instâncias)

  factory AlunoVo.fromMap(Map<String, dynamic> map) {
    return AlunoVo(
      id: map['id'],
      ra: map['ra'],
      nomeCompleto: map['nomeCompleto'],
      email: map['email'],
      dataNascimento: DateTime.parse(map['dataNascimento']), // aquele ISO
      sexo: SexoEnum.values[map['sexo']],
      curso: CursoEnum.values[map['curso']],
      matriculado: map['matriculado'] == 1,
    );
  }

  // toMap funciona como conversão em banco de dados para INSERT | UPDATE
  // fromMap a conversão para usar como SELECT
}

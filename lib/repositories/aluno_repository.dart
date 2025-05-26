import 'package:tarefa2/exceptions/aluno_not_found_exception.dart';
import 'package:tarefa2/models/aluno_vo.dart';
import 'package:tarefa2/enums/sexo_enum.dart';
import 'package:tarefa2/enums/curso_enum.dart';

// essa classe simula uma tabela de ALUNOS (em memória)
// se precisa criar professores depois, bastaria criar outra classe

class AlunoRepository {
  // Interessante a ser estudado:

  // design pattern (padrão de projeto) = Singleton (única instância da classe)
  // refactoring guru

  // 3. primeira e única instanciação do atributo '_instance'
  static final AlunoRepository _instance = AlunoRepository._internal();

  // 1. construtor privado (reduz o escopo à classe - não pode cahamr por fora)
  AlunoRepository._internal();

  // 2. método classe que funciona como construtor
  // retorna sempre a mesma referência (instância) que é o atributo '_instance'
  factory AlunoRepository() {
    return _instance;
  }

  final Map<String, AlunoVo> _alunos = {
    '1': AlunoVo(
      id: '1',
      ra: '100',
      nomeCompleto: 'João Silva',
      email: 'joao.silva@gmail.com',
      dataNascimento: DateTime(2000, 5, 15),
      sexo: SexoEnum.masculino,
      curso: CursoEnum.analise,
      matriculado: true,
    ),
    '2': AlunoVo(
      id: '2',
      ra: '101',
      nomeCompleto: 'Maria Oliveira',
      email: 'maria.oliveira@gmail.com',
      dataNascimento: DateTime(1999, 8, 22),
      sexo: SexoEnum.feminino,
      curso: CursoEnum.medicina,
      matriculado: false,
    )
  };

  void save(AlunoVo aluno) {
    // INSERT INTO ALUNOS (...) VALUES (...);
    // UPDATE ALUNOS SET RA = ? ... WHERE ID = ?;
    _alunos[aluno.id] = aluno;
  }

  AlunoVo findById(String id) {
    // se não foi possível encontrar aluno pelo/com id
    if (!_alunos.containsKey(id)) {
      throw AlunoNotFoundException(id);
    }
    return _alunos[id]!; // sei que sempre vai ter um aluno com esse id
  }

  List<AlunoVo> findByRaOrName(String valor) {
    final String termo =
        valor.toLowerCase(); // case sensitive (minúsculo/maiúsculo)
    final List<AlunoVo> alunos =
        _alunos.values
            .where(
              (aluno) =>
                  aluno.ra.toLowerCase().contains(termo) ||
                  aluno.nomeCompleto.toLowerCase().contains(termo),
            )
            .toList();

    if (alunos.isEmpty) {
      throw AlunoNotFoundException(valor, isId: false);
    }

    return alunos;
  }

  List<AlunoVo> findAll() {
    return _alunos.values.toList();
  }

  void deleteById(String id) {
    if (!_alunos.containsKey(id)) {
      throw AlunoNotFoundException(id);
    }
    _alunos.remove(id);
  }
}

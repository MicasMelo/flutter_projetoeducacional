import 'package:tarefa2/exceptions/professor_not_found_exception.dart';
import 'package:tarefa2/models/professor_vo.dart';
import 'package:tarefa2/enums/sexo_enum.dart';
import 'package:tarefa2/enums/curso_enum.dart';

// essa classe simula uma tabela de PROFESSORES (em memória)

class ProfessorRepository {
  static final ProfessorRepository _instance = ProfessorRepository._internal();

  ProfessorRepository._internal();

  factory ProfessorRepository() {
    return _instance;
  }

  final Map<String, ProfessorVo> _professores = {
    '1': ProfessorVo(
      id: '1',
      cpf: '46315276751',
      nomeCompleto: 'Veridico Juciliano',
      email: 'veri.ciciliano@gmail.com',
      dataNascimento: DateTime(1988, 5, 30),
      sexo: SexoEnum.masculino,
      curso: CursoEnum.direito,
      ativo: true,
    )
  };

  void save(ProfessorVo professor) {
    _professores[professor.id] = professor;
  }

  ProfessorVo findById(String id) {
    if (!_professores.containsKey(id)) {
      throw ProfessorNotFoundException(id);
    }
    return _professores[id]!;
  }

  List<ProfessorVo> findByCPFOrName(String valor) {
    final String termo =
        valor.toLowerCase();
    final List<ProfessorVo> professores =
        _professores.values
            .where(
              (professor) =>
                  professor.cpf.toLowerCase().contains(termo) ||
                  professor.nomeCompleto.toLowerCase().contains(termo),
            )
            .toList();

    if (professores.isEmpty) {
      throw ProfessorNotFoundException(valor, isId: false);
    }

    return professores;
  }

  List<ProfessorVo> findAll() {
    return _professores.values.toList();
  }

  void deleteById(String id) {
    if (!_professores.containsKey(id)) {
      throw ProfessorNotFoundException(id);
    }
    _professores.remove(id);
  }
}
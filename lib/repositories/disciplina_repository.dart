import 'package:tarefa2/enums/modalidade_enum.dart';
import 'package:tarefa2/exceptions/disciplina_not_found_exception.dart';
import 'package:tarefa2/models/disciplina_vo.dart';
import 'package:tarefa2/enums/curso_enum.dart';

// essa classe simula uma tabela de DISCIPLINAS (em memória)

class DisciplinaRepository {
  static final DisciplinaRepository _instance = DisciplinaRepository._internal();

  DisciplinaRepository._internal();

  factory DisciplinaRepository() {
    return _instance;
  }

  final Map<String, DisciplinaVo> _disciplinas = {
    '1': DisciplinaVo(
      id: '1',
      nome: 'Gestão de Projetos',
      curso: CursoEnum.analise,
      modalidade: ModalidadeEnum.presencial,
      dataCriacao: DateTime(2025, 5, 25),
      ativo: true,
    )
  };

  void save(DisciplinaVo disciplina) {
    _disciplinas[disciplina.id] = disciplina;
  }

  DisciplinaVo findById(String id) {
    if (!_disciplinas.containsKey(id)) {
      throw DisciplinaNotFoundException(id);
    }
    return _disciplinas[id]!;
  }

  List<DisciplinaVo> findByCPFOrName(String valor) {
    final String termo =
        valor.toLowerCase();
    final List<DisciplinaVo> disciplinas =
        _disciplinas.values
            .where(
              (disciplina) =>
                  disciplina.nome.toLowerCase().contains(termo)
            )
            .toList();

    if (disciplinas.isEmpty) {
      throw DisciplinaNotFoundException(valor, isId: false);
    }

    return disciplinas;
  }

  List<DisciplinaVo> findAll() {
    return _disciplinas.values.toList();
  }

  void deleteById(String id) {
    if (!_disciplinas.containsKey(id)) {
      throw DisciplinaNotFoundException(id);
    }
    _disciplinas.remove(id);
  }
}
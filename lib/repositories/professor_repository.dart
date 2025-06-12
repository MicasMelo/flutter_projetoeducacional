import 'package:sqflite/sqflite.dart';
import 'package:tarefa2/database/database_central.dart';
import 'package:tarefa2/exceptions/professor_not_found_exception.dart';
import 'package:tarefa2/models/professor_vo.dart';

class ProfessorRepository {
  final dbFuture = DatabaseProvider().database;

  Future<void> save(ProfessorVo professor) async {
    final db = await dbFuture;
    await db.insert(
      'professores',
      professor.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ProfessorVo> findById(String id) async {
    final db = await dbFuture;
    final maps = await db.query('professores', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) {
      throw ProfessorNotFoundException(id);
    }

    return ProfessorVo.fromMap(maps.first);
  }

  Future<List<ProfessorVo>> findByCPFOrNome(String valor) async {
    final termo = valor.toLowerCase();
    final db = await dbFuture;
    final maps = await db.query('professores');

    final professores =
        maps
            .where(
              (map) =>
                  map['cpf'].toString().toLowerCase().contains(termo) ||
                  map['nomeCompleto'].toString().toLowerCase().contains(termo),
            )
            .map((map) => ProfessorVo.fromMap(map))
            .toList();

    if (professores.isEmpty) {
      throw ProfessorNotFoundException(valor, isId: false);
    }

    return professores;
  }

  Future<List<ProfessorVo>> findAll() async {
    final db = await dbFuture;
    final maps = await db.query('professores');
    return maps.map((map) => ProfessorVo.fromMap(map)).toList();
  }

  Future<void> deleteById(String id) async {
    final db = await dbFuture;
    final count = await db.delete('professores', where: 'id = ?', whereArgs: [id]);

    if (count == 0) {
      throw ProfessorNotFoundException(id);
    }
  }
}
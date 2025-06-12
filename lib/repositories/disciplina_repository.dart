import 'package:sqflite/sqflite.dart';
import 'package:tarefa2/database/database_central.dart';
import 'package:tarefa2/exceptions/disciplina_not_found_exception.dart';
import 'package:tarefa2/models/disciplina_vo.dart';

class DisciplinaRepository {
  final dbFuture = DatabaseProvider().database;
  
  Future<void> save(DisciplinaVo disciplina) async {
    final db = await dbFuture;
    await db.insert(
      'disciplinas',
      disciplina.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DisciplinaVo> findById(String id) async {
    final db = await dbFuture;
    final maps = await db.query('disciplinas', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) {
      throw DisciplinaNotFoundException(id);
    }

    return DisciplinaVo.fromMap(maps.first);
  }

  Future<List<DisciplinaVo>> findByName(String valor) async {
    final termo = valor.toLowerCase();
    final db = await dbFuture;
    final maps = await db.query('disciplinas');

    final disciplinas =
        maps
            .where(
              (map) =>
                  map['nome'].toString().toLowerCase().contains(termo),
            )
            .map((map) => DisciplinaVo.fromMap(map))
            .toList();

    if (disciplinas.isEmpty) {
      throw DisciplinaNotFoundException(valor, isId: false);
    }

    return disciplinas;
  }

  Future<List<DisciplinaVo>> findAll() async {
    final db = await dbFuture;
    final maps = await db.query('disciplinas');
    return maps.map((map) => DisciplinaVo.fromMap(map)).toList();
  }

  Future<void> deleteById(String id) async {
    final db = await dbFuture;
    final count = await db.delete('disciplinas', where: 'id = ?', whereArgs: [id]);

    if (count == 0) {
      throw DisciplinaNotFoundException(id);
    }
  }
}
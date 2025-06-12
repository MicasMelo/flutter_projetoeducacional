import 'package:sqflite/sqflite.dart';
import 'package:tarefa2/exceptions/aluno_not_found_exception.dart';
import 'package:tarefa2/models/aluno_vo.dart';
import 'package:tarefa2/database/database_central.dart';

class AlunoRepository {
  final dbFuture = DatabaseProvider().database;

  Future<void> save(AlunoVo aluno) async {
    final db = await dbFuture;
    await db.insert(
      'alunos',
      aluno.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AlunoVo> findById(String id) async {
    final db = await dbFuture;
    final maps = await db.query('alunos', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) {
      throw AlunoNotFoundException(id);
    }

    return AlunoVo.fromMap(maps.first);
  }

  Future<List<AlunoVo>> findByRaOrNome(String valor) async {
    final termo = valor.toLowerCase();
    final db = await dbFuture;
    final maps = await db.query('alunos');

    final alunos =
        maps
            .where(
              (map) =>
                  map['ra'].toString().toLowerCase().contains(termo) ||
                  map['nomeCompleto'].toString().toLowerCase().contains(termo),
            )
            .map((map) => AlunoVo.fromMap(map))
            .toList();

    if (alunos.isEmpty) {
      throw AlunoNotFoundException(valor, isId: false);
    }

    return alunos;
  }

  Future<List<AlunoVo>> findAll() async {
    final db = await dbFuture;
    final maps = await db.query('alunos');
    return maps.map((map) => AlunoVo.fromMap(map)).toList();
  }

  Future<void> deleteById(String id) async {
    final db = await dbFuture;
    final count = await db.delete('alunos', where: 'id = ?', whereArgs: [id]);

    if (count == 0) {
      throw AlunoNotFoundException(id);
    }
  }
}

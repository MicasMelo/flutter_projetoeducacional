import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tarefa2/exceptions/professor_not_found_exception.dart';
import 'package:tarefa2/models/professor_vo.dart';
import 'package:tarefa2/enums/sexo_enum.dart';
import 'package:tarefa2/enums/curso_enum.dart';

// essa classe simula uma tabela de PROFESSORES (em memória)

class ProfessorRepository {
  static final ProfessorRepository _instance = ProfessorRepository._internal();
  static Database? _database;

  ProfessorRepository._internal();

  factory ProfessorRepository() {
    return _instance;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'academico_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE professores(
        id TEXT PRIMARY KEY,
        cpf TEXT NOT NULL,
        nomeCompleto TEXT NOT NULL,
        email TEXT NOT NULL,
        dataNascimento TEXT NOT NULL,
        sexo INTEGER NOT NULL,
        curso INTEGER NOT NULL,
        ativo INTEGER NOT NULL
      )
    ''');

    await _insertInitialData(db);
  }

  Future<Database> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // ...
    return db;
  }

  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    throw UnsupportedError('Downgrade de banco de dados não suportado');
  }

  Future<void> _insertInitialData(Database db) async {
    final professoresIniciais = [
      ProfessorVo(
        id: '1',
      cpf: '46315276751',
      nomeCompleto: 'Veridico Juciliano',
      email: 'veri.ciciliano@gmail.com',
      dataNascimento: DateTime(1988, 5, 30),
      sexo: SexoEnum.masculino,
      curso: CursoEnum.direito,
      ativo: true,
      )
    ];

    for (final professor in professoresIniciais) {
      await db.insert('professores', professor.toMap());
    }
  }

  Future<void> save(ProfessorVo professor) async {
    final db = await database;
    await db.insert(
      'professores',
      professor.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ProfessorVo> findById(String id) async {
    final db = await database;
    final maps = await db.query('professores', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) {
      throw ProfessorNotFoundException(id);
    }

    return ProfessorVo.fromMap(maps.first);
  }

  Future<List<ProfessorVo>> findByCPFOrNome(String valor) async {
    final termo = valor.toLowerCase();
    final db = await database;
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
    final db = await database;
    final maps = await db.query('professores');
    return maps.map((map) => ProfessorVo.fromMap(map)).toList();
  }

  Future<void> deleteById(String id) async {
    final db = await database;
    final count = await db.delete('professores', where: 'id = ?', whereArgs: [id]);

    if (count == 0) {
      throw ProfessorNotFoundException(id);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
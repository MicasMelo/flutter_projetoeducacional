import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tarefa2/enums/modalidade_enum.dart';
import 'package:tarefa2/exceptions/disciplina_not_found_exception.dart';
import 'package:tarefa2/models/disciplina_vo.dart';
import 'package:tarefa2/enums/curso_enum.dart';

// essa classe simula uma tabela de DISCIPLINAS (em memória)

class DisciplinaRepository {
  static final DisciplinaRepository _instance = DisciplinaRepository._internal();
  static Database? _database;

  DisciplinaRepository._internal();

  factory DisciplinaRepository() {
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
      CREATE TABLE disciplinas(
        id TEXT PRIMARY KEY,
        nome TEXT NOT NULL,
        dataCriacao TEXT NOT NULL,
        curso INTEGER NOT NULL,
        modalidade INTEGER NOT NULL,
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
    final disciplinasIniciais = [
      DisciplinaVo(
        id: '1',
      nome: 'Gestão de Projetos',
      curso: CursoEnum.analise,
      modalidade: ModalidadeEnum.presencial,
      dataCriacao: DateTime(2025, 5, 25),
      ativo: true,
      )
    ];

    for (final disciplina in disciplinasIniciais) {
      await db.insert('disciplinas', disciplina.toMap());
    }
  }

  Future<void> save(DisciplinaVo disciplina) async {
    final db = await database;
    await db.insert(
      'disciplinas',
      disciplina.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DisciplinaVo> findById(String id) async {
    final db = await database;
    final maps = await db.query('disciplinas', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) {
      throw DisciplinaNotFoundException(id);
    }

    return DisciplinaVo.fromMap(maps.first);
  }

  Future<List<DisciplinaVo>> findByName(String valor) async {
    final termo = valor.toLowerCase();
    final db = await database;
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
    final db = await database;
    final maps = await db.query('disciplinas');
    return maps.map((map) => DisciplinaVo.fromMap(map)).toList();
  }

  Future<void> deleteById(String id) async {
    final db = await database;
    final count = await db.delete('disciplinas', where: 'id = ?', whereArgs: [id]);

    if (count == 0) {
      throw DisciplinaNotFoundException(id);
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
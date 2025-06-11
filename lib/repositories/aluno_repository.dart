import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tarefa2/exceptions/aluno_not_found_exception.dart';
import 'package:tarefa2/models/aluno_vo.dart';
import 'package:tarefa2/enums/sexo_enum.dart';
import 'package:tarefa2/enums/curso_enum.dart';

// essa classe simula uma tabela de ALUNOS (em memória)
// se precisa criar professores depois, bastaria criar outra classe

class AlunoRepository {
  static final AlunoRepository _instance = AlunoRepository._internal();
  static Database? _database;

  AlunoRepository._internal();

  factory AlunoRepository() {
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
      CREATE TABLE alunos(
        id TEXT PRIMARY KEY,
        ra TEXT NOT NULL,
        nomeCompleto TEXT NOT NULL,
        email TEXT NOT NULL,
        dataNascimento TEXT NOT NULL,
        sexo INTEGER NOT NULL,
        curso INTEGER NOT NULL,
        matriculado INTEGER NOT NULL
      )
    ''');

    // Inserir dados iniciais
    await _insertInitialData(db);
  }

  Future<Database> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    /*
    await db.transaction((txn) async {
      // Migração da versão 1 para 2
      if (oldVersion < 2) {
        await txn.execute('''
        ALTER TABLE alunos ADD COLUMN telefone TEXT
      ''');

        await txn.execute('''
        ALTER TABLE alunos ADD COLUMN ativo INTEGER DEFAULT 1
      ''');

        // Migração de dados: define todos os alunos como ativos
        await txn.update('alunos', {'ativo': 1}, where: 'ativo IS NULL');
      }

      // Migração da versão 2 para 3
      if (oldVersion < 3) {
        // Cria uma nova tabela para histórico de matrículas
        await txn.execute('''
        CREATE TABLE historico_matriculas(
          id TEXT PRIMARY KEY,
          aluno_id TEXT NOT NULL,
          data TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          tipo TEXT NOT NULL CHECK(tipo IN ('MATRICULA', 'CANCELAMENTO')),
          FOREIGN KEY (aluno_id) REFERENCES alunos(id) ON DELETE CASCADE
        )
      ''');

        // Migra os alunos matriculados para o histórico
        final matriculados = await txn.query(
          'alunos',
          columns: ['id'],
          where: 'matriculado = 1',
        );

        for (final aluno in matriculados) {
          await txn.insert('historico_matriculas', {
            'id': const Uuid().v4(),
            'aluno_id': aluno['id'],
            'tipo': 'MATRICULA',
            'data': DateTime.now().toIso8601String(),
          });
        }
      }

      // Migração da versão 3 para 4
      if (oldVersion < 4) {
        // Normaliza o campo curso para uma tabela separada
        await txn.execute('''
        CREATE TABLE cursos(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nome TEXT NOT NULL UNIQUE
        )
      ''');

        // Insere os cursos padrão
        await txn.insert('cursos', {'nome': 'Análise de Sistemas'});
        await txn.insert('cursos', {'nome': 'Medicina'});
        // ... outros cursos

        // Adiciona a coluna curso_id e migra os dados
        await txn.execute('''
        ALTER TABLE alunos ADD COLUMN curso_id INTEGER
      ''');

        // Atualiza os cursos existentes (mock de migração)
        await txn.rawUpdate('''
        UPDATE alunos SET curso_id = 1 WHERE curso = 0
      ''');
        await txn.rawUpdate('''
        UPDATE alunos SET curso_id = 2 WHERE curso = 1
      ''');

        // Remove a coluna antiga (opcional - pode manter durante período de transição)
        // await txn.execute('ALTER TABLE alunos DROP COLUMN curso');
      }
    });
    */

    return db;
  }

  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    throw UnsupportedError('Downgrade de banco de dados não suportado');
  }

  Future<void> _insertInitialData(Database db) async {
    final alunosIniciais = [
      AlunoVo(
        id: '1',
        ra: '100',
        nomeCompleto: 'João Silva',
        email: 'joao.silva@email.com',
        dataNascimento: DateTime(2000, 5, 15),
        sexo: SexoEnum.masculino,
        curso: CursoEnum.analise,
        matriculado: true,
      ),
      AlunoVo(
        id: '2',
        ra: '101',
        nomeCompleto: 'Maria Oliveira',
        email: 'maria.oliveira@email.com',
        dataNascimento: DateTime(1999, 8, 22),
        sexo: SexoEnum.feminino,
        curso: CursoEnum.medicina,
        matriculado: false,
      ),
    ];

    for (final aluno in alunosIniciais) {
      await db.insert('alunos', aluno.toMap());
    }
  }

  Future<void> save(AlunoVo aluno) async {
    final db = await database;
    await db.insert(
      'alunos',
      aluno.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<AlunoVo> findById(String id) async {
    final db = await database;
    final maps = await db.query('alunos', where: 'id = ?', whereArgs: [id]);

    if (maps.isEmpty) {
      throw AlunoNotFoundException(id);
    }

    return AlunoVo.fromMap(maps.first);
  }

  Future<List<AlunoVo>> findByRaOrNome(String valor) async {
    final termo = valor.toLowerCase();
    final db = await database;
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
    final db = await database;
    final maps = await db.query('alunos');
    return maps.map((map) => AlunoVo.fromMap(map)).toList();
  }

  Future<void> deleteById(String id) async {
    final db = await database;
    final count = await db.delete('alunos', where: 'id = ?', whereArgs: [id]);

    if (count == 0) {
      throw AlunoNotFoundException(id);
    }
  }

  // Método para fechar a conexão com o banco de dados (opcional)
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

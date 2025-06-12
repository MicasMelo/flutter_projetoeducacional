import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:tarefa2/enums/curso_enum.dart';
import 'package:tarefa2/enums/modalidade_enum.dart';
import 'package:tarefa2/enums/sexo_enum.dart';
import 'package:tarefa2/models/aluno_vo.dart';
import 'package:tarefa2/models/disciplina_vo.dart';
import 'package:tarefa2/models/professor_vo.dart';

class DatabaseProvider {
  static final DatabaseProvider _instance = DatabaseProvider._internal();
  static Database? _database;

  DatabaseProvider._internal();

  factory DatabaseProvider() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'academico_database.db');
    // await deleteDatabase(path); // caso o banco de dados dê problema em reconhecer todas as tabelas criadas ou se necessário resetar
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alunos (
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

    await db.execute('''
      CREATE TABLE professores (
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

    await db.execute('''
      CREATE TABLE disciplinas (
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

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}

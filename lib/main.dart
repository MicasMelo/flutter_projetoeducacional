import 'package:tarefa2/enums/curso_enum.dart';
import 'package:tarefa2/enums/modalidade_enum.dart';
import 'package:tarefa2/enums/sexo_enum.dart';
import 'package:tarefa2/models/aluno_vo.dart';
import 'package:tarefa2/models/disciplina_vo.dart';
import 'package:tarefa2/models/professor_vo.dart';
import 'package:tarefa2/repositories/aluno_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tarefa2/repositories/disciplina_repository.dart';
import 'package:tarefa2/repositories/professor_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: false),
      home: HomePage(),
    );
  }
}

// enums (enumerações = conjunto predefinido de valores)
// models (VO = value objects = modelo/estrutura de dados)
// exceptions (exceções = falhas)
// repositories (DAO = data access object = persistência)
//    in memory > indexeddb ou sqlflite

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.add_outlined),
            onSelected: (value) {
              switch (value) {
                case 'aluno':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AlunoFormPage()),
                  );
                  break;
                case 'professor':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfessorFormPage()),
                  );
                  break;
                case 'disciplina':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DisciplinaFormPage()),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'aluno',
                child: Text('Adicionar Aluno'),
              ),
              const PopupMenuItem<String>(
                value: 'professor',
                child: Text('Adicionar Professor'),
              ),
              const PopupMenuItem<String>(
                value: 'disciplina',
                child: Text('Adicionar Disciplina'),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.list_outlined),
            onSelected: (value) {
              switch (value) {
                case 'aluno':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AlunoListPage()),
                  );
                  break;
                case 'professor':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfessorListPage()),
                  );
                  break;
                case 'disciplina':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => DisciplinaListPage()),
                  );
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'aluno',
                child: Text('Listar Alunos'),
              ),
              const PopupMenuItem<String>(
                value: 'professor',
                child: Text('Listar Professores'),
              ),
              const PopupMenuItem<String>(
                value: 'disciplina',
                child: Text('Listar Disciplinas'),
              ),
            ],
          )
        ]
      )
    );
  }
}

class AlunoFormPage extends StatefulWidget {
  //statefull porque vou precisar guardar dados
  final String? alunoId; // alunoId pode existir ou não (vira novo)

  // construtor
  const AlunoFormPage({super.key, this.alunoId});

  @override
  State<AlunoFormPage> createState() => _AlunoFormPageState();
}

class ProfessorFormPage extends StatefulWidget {
  final String? professorID;

  const ProfessorFormPage({super.key, this.professorID});

  @override
  State<ProfessorFormPage> createState() => _ProfessorFormPageState();
}

class DisciplinaFormPage extends StatefulWidget {
  final String? disciplinaId;

  const DisciplinaFormPage({super.key, this.disciplinaId});

  @override
  State<DisciplinaFormPage> createState() => _DisciplinaFormPageState();
}

class _AlunoFormPageState extends State<AlunoFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _repository = AlunoRepository();

  final _raController = TextEditingController();
  final _nomeCompletoController = TextEditingController();
  final _emailController = TextEditingController();
  final _dataNascimentoController = TextEditingController();

  SexoEnum? _sexo;
  CursoEnum? _curso;
  bool _matriculado = false;

  AlunoVo? _aluno;

  @override
  void dispose() {
    _raController.dispose();
    _nomeCompletoController.dispose();
    _emailController.dispose();
    _dataNascimentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_aluno == null ? 'Novo Aluno' : 'Edição de Aluno'),
        actions: [
          IconButton(
            onPressed: () {
              _salvar();
            },
            icon: Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _raController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'RA (Registro Acadêmico)',
                  hintText: '123',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'RA é obrigatório';
                  } else if (value.length != 3) {
                    return 'RA deve ter exatamente 3 dígitos';
                  }
                  return null; // campo validado
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nomeCompletoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nome completo',
                  hintText: 'Digite o nome completo',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome completo é obrigatório';
                  } else if (value.length < 10) {
                    return 'Nome deve possuir pelo menos 10 caracteres';
                  } else if (value.length > 50) {
                    return 'Nome deve ter até 50 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'E-mail',
                  hintText: 'example@fema.edu.br',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'E-mail é obrigatório';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _dataNascimentoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Data de Nascimento',
                  hintText: 'DD/MM/AAAA',
                ),
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                  _DateInputFormatter(), // para criar nossas formatação própia
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Data de nascimento é obrigatório';
                  } else if (value.length != 10) {
                    return 'Data inválida';
                  }
                  try {
                    // "01/01/1990" = Datetime
                    // transformar split "01/01/1990" em ["01", "01", "1990"], outros pequenos vetores
                    final parts = value.split('/');
                    final day = int.parse(parts[0]);
                    final month = int.parse(parts[1]);
                    final year = int.parse(parts[2]);
                    final data = DateTime(year,month,day);

                    if (data.isAfter(DateTime.now())) {
                      return 'Data não pode ser do futuro';
                    }


                    int idade = DateTime.now().year - year;
                    if (DateTime.now().month < month ||
                        DateTime.now().month == month &&
                          DateTime.now().day < day) {
                      idade--;
                    }

                    if (idade < 16) {
                      return 'Aluno deve ter pelo menos 16 anos';
                    }
                  } catch (e){
                    return 'Data inválida';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<SexoEnum>(
                value: _sexo,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Sexo',
                ),
                items:
                    SexoEnum.values
                        .map(
                          (sexo) => DropdownMenuItem(
                            value: sexo,
                            child: Text(sexo.descricao),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _sexo = value;
                  });
                },
                validator: (value) {
                  if (_sexo == null) {
                    return 'Sexo é obrigatório';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<CursoEnum>(
                value: _curso,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Curso',
                ),
                items:
                    CursoEnum.values
                        .map(
                          (curso) => DropdownMenuItem(
                            value: curso,
                            child: Text(curso.descricao),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _curso = value;
                  });
                },
                validator: (value) {
                  if (_curso == null) {
                    return 'Curso é obrigatório';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                title: Text('Matriculado'),
                value: _matriculado,
                onChanged: (value) {
                  setState(() {
                    _matriculado = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final parts = _dataNascimentoController.text.split('/');
      final dataNascimento = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0])
      );
      final aluno = AlunoVo(
        id: _aluno?.id,
        ra: _raController.text,
        nomeCompleto: _nomeCompletoController.text,
        email: _emailController.text,
        dataNascimento: dataNascimento,
        sexo: _sexo!,
        curso: _curso!,
        matriculado: _matriculado
      );
      _repository.save(aluno);
      ScaffoldMessenger.of(context).clearSnackBars(); // limpa as notificações
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Aluno salvo com sucesso!'))
      );
      Navigator.of(context).pop(); // finaliza a tela de formulário
    }
  }
}

class AlunoListPage extends StatefulWidget {
  const AlunoListPage({super.key});

  @override
  State<AlunoListPage> createState() => _AlunoListPageState();
}

class _AlunoListPageState extends State<AlunoListPage> {
  final AlunoRepository _repository = AlunoRepository();
  late List<AlunoVo> _alunos;

  @override
  void initState() {
    super.initState();
    _carregarAlunos();
  }

  void _carregarAlunos() {
    setState(() {
      _alunos = _repository.findAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listagem de Alunos'),
        actions: [IconButton(onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => AlunoFormPage())
          ).then((_) => _carregarAlunos());
        }, icon: Icon(Icons.add_outlined))]
      ),
      body: _alunos.isEmpty ? Center(
        child: Text('Nenhum aluno cadastrado',
          style: Theme.of(context).textTheme.titleLarge
        )
      ) : ListView.builder(
            itemCount: _alunos.length,
            itemBuilder: (context, index) {
              return _buildAlunoTile(_alunos[index]);
            }
          )
    );
  }

  Widget _buildAlunoTile(AlunoVo aluno) {
    return Dismissible(
      key: Key(aluno.id),
      background: Container(
        color: Colors.blue,
        child: Center(
          child: Icon(Icons.edit_outlined, color: Colors.white)
        )
      ),
      secondaryBackground: Container(
        color: Colors.red,
        child: Center(
          child: Icon(Icons.delete_outlined, color: Colors.white)
        )
      ),
      child: ListTile(
        leading: Icon(
          Icons.person_outlined,
          color: aluno.sexo == SexoEnum.masculino ? Colors.blue : Colors.pink,
          size: 36,
        ),
        title: Text(aluno.nomeCompleto),
        subtitle: Text(aluno.ra),
        trailing:
            aluno.matriculado
                ? const Icon(Icons.check_circle_outlined, color: Colors.green)
                : const Icon(Icons.cancel_outlined, color: Colors.red),
        onTap: () => _mostrarDetalhesAluno(aluno),
      )
    );
  }

  void _mostrarDetalhesAluno(AlunoVo aluno) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(aluno.nomeCompleto),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RA: ${aluno.ra}'),
              Text('Curso: ${aluno.curso.descricao}'),
              Text('Idade: ${aluno.idade} anos'),
              Text(
                'Status: ${aluno.matriculado ? 'Matriculado' : 'Não matriculado'}',
              )
            ]
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}

class _ProfessorFormPageState extends State<ProfessorFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _repository = ProfessorRepository();

  final _cpfController = TextEditingController();
  final _nomeCompletoController = TextEditingController();
  final _emailController = TextEditingController();
  final _dataNascimentoController = TextEditingController();

  SexoEnum? _sexo;
  CursoEnum? _curso;
  bool _ativo = false;

  ProfessorVo? _professor;

  @override
  void dispose() {
    _cpfController.dispose();
    _nomeCompletoController.dispose();
    _emailController.dispose();
    _dataNascimentoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_professor == null ? 'Novo Professor' : 'Edição de Professor'),
        actions: [
          IconButton(
            onPressed: () {
              _salvar();
            },
            icon: Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _cpfController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'CPF',
                  hintText: '12345678900',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'CPF é obrigatório';
                  } else if (value.length != 11) {
                    return 'CPF deve ter exatamente 11 dígitos';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _nomeCompletoController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nome completo',
                  hintText: 'Digite o nome completo',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome completo é obrigatório';
                  } else if (value.length < 10) {
                    return 'Nome deve possuir pelo menos 10 caracteres';
                  } else if (value.length > 50) {
                    return 'Nome deve ter até 50 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'E-mail',
                  hintText: 'example@fema.edu.br',
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'E-mail é obrigatório';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _dataNascimentoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Data de Nascimento',
                  hintText: 'DD/MM/AAAA',
                ),
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                  _DateInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Data de nascimento é obrigatório';
                  } else if (value.length != 10) {
                    return 'Data inválida';
                  }
                  try {
                    final parts = value.split('/');
                    final day = int.parse(parts[0]);
                    final month = int.parse(parts[1]);
                    final year = int.parse(parts[2]);
                    final data = DateTime(year,month,day);

                    if (data.isAfter(DateTime.now())) {
                      return 'Data não pode ser do futuro';
                    }


                    int idade = DateTime.now().year - year;
                    if (DateTime.now().month < month ||
                        DateTime.now().month == month &&
                          DateTime.now().day < day) {
                      idade--;
                    }

                    if (idade < 18) {
                      return 'Professor deve ter pelo menos 18 anos';
                    }
                  } catch (e){
                    return 'Data inválida';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<SexoEnum>(
                value: _sexo,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Sexo',
                ),
                items:
                    SexoEnum.values
                        .map(
                          (sexo) => DropdownMenuItem(
                            value: sexo,
                            child: Text(sexo.descricao),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _sexo = value;
                  });
                },
                validator: (value) {
                  if (_sexo == null) {
                    return 'Sexo é obrigatório';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<CursoEnum>(
                value: _curso,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Área Principal de Ensino',
                ),
                items:
                    CursoEnum.values
                        .map(
                          (curso) => DropdownMenuItem(
                            value: curso,
                            child: Text(curso.descricao),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _curso = value;
                  });
                },
                validator: (value) {
                  if (_curso == null) {
                    return 'Área / Curso é obrigatório';
                  }
                  return null;
                },
              ),
              CheckboxListTile(
                title: Text('Ativo'),
                value: _ativo,
                onChanged: (value) {
                  setState(() {
                    _ativo = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final parts = _dataNascimentoController.text.split('/');
      final dataNascimento = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0])
      );
      final professor = ProfessorVo(
        id: _professor?.id,
        cpf: _cpfController.text,
        nomeCompleto: _nomeCompletoController.text,
        email: _emailController.text,
        dataNascimento: dataNascimento,
        sexo: _sexo!,
        curso: _curso!,
        ativo: _ativo
      );
      _repository.save(professor);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Professor salvo com sucesso!'))
      );
      Navigator.of(context).pop();
    }
  }
}

class ProfessorListPage extends StatefulWidget {
  const ProfessorListPage({super.key});

  @override
  State<ProfessorListPage> createState() => _ProfessorListPageState();
}

class _ProfessorListPageState extends State<ProfessorListPage> {
  final ProfessorRepository _repository = ProfessorRepository();
  late List<ProfessorVo> _professores;

  @override
  void initState() {
    super.initState();
    _carregarProfessores();
  }

  void _carregarProfessores() {
    setState(() {
      _professores = _repository.findAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listagem de Professores'),
        actions: [IconButton(onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ProfessorFormPage())
          ).then((_) => _carregarProfessores());
        }, icon: Icon(Icons.add_outlined))]
      ),
      body: _professores.isEmpty ? Center(
        child: Text('Nenhum professor cadastrado',
          style: Theme.of(context).textTheme.titleLarge
        )
      ) : ListView.builder(
            itemCount: _professores.length,
            itemBuilder: (context, index) {
              return _buildProfessorTile(_professores[index]);
            }
          )
    );
  }

  Widget _buildProfessorTile(ProfessorVo professor) {
    return Dismissible(
      key: Key(professor.id),
      background: Container(
        color: Colors.blue,
        child: Center(
          child: Icon(Icons.edit_outlined, color: Colors.white)
        )
      ),
      secondaryBackground: Container(
        color: Colors.red,
        child: Center(
          child: Icon(Icons.delete_outlined, color: Colors.white)
        )
      ),
      child: ListTile(
        leading: Icon(
          Icons.person_outlined,
          color: professor.sexo == SexoEnum.masculino ? Colors.blue : Colors.pink,
          size: 36,
        ),
        title: Text(professor.nomeCompleto),
        subtitle: Text(professor.cpf),
        trailing:
            professor.ativo
                ? const Icon(Icons.check_circle_outlined, color: Colors.green)
                : const Icon(Icons.cancel_outlined, color: Colors.red),
        onTap: () => _mostrarDetalhesProfessor(professor),
      )
    );
  }

  void _mostrarDetalhesProfessor(ProfessorVo professor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(professor.nomeCompleto),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('RA: ${professor.cpf}'),
              Text('Curso: ${professor.curso.descricao}'),
              Text('Idade: ${professor.idade} anos'),
              Text(
                'Status: ${professor.ativo ? 'Ativo' : 'Desativado'}',
              )
            ]
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}

class _DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final String text = newValue.text.replaceAll(r'[^0-9]', '');

    if (text.length > 8) {
      return oldValue;
    }

    String formatted = '';
    if (text.length >= 2) {
      formatted += '${text.substring(0, 2)}/';
      if (text.length >= 4) {
        formatted += '${text.substring(2, 4)}/';
        if (text.length > 4) {
          formatted += text.substring(4); // dia + '/' + mês + '/' + ano
        }
      } else {
        formatted += text.substring(2);
      }
    } else {
      formatted = text;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _DisciplinaFormPageState extends State<DisciplinaFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _repository = DisciplinaRepository();

  final _nomeController = TextEditingController();
  final _dataCriacaoController = TextEditingController();

  CursoEnum? _curso;
  ModalidadeEnum? _modalidade;
  bool _ativo = false;

  DisciplinaVo? _disciplina;

  @override
  void dispose() {
    _nomeController.dispose();
    _dataCriacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_disciplina == null ? 'Nova Disciplina' : 'Edição de Disciplina'),
        actions: [
          IconButton(
            onPressed: () {
              _salvar();
            },
            icon: Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Nome da disciplina',
                  hintText: 'Digite o nome da disciplina',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nome da disciplina é obrigatório';
                  } else if (value.length < 10) {
                    return 'Nome deve possuir pelo menos 10 caracteres';
                  } else if (value.length > 50) {
                    return 'Nome deve ter até 50 caracteres';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<CursoEnum>(
                value: _curso,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Curso Associado',
                ),
                items:
                    CursoEnum.values
                        .map(
                          (curso) => DropdownMenuItem(
                            value: curso,
                            child: Text(curso.descricao),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _curso = value;
                  });
                },
                validator: (value) {
                  if (_curso == null) {
                    return 'Curso é obrigatório';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<ModalidadeEnum>(
                value: _modalidade,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Modalidade',
                ),
                items:
                    ModalidadeEnum.values
                        .map(
                          (modalidade) => DropdownMenuItem(
                            value: modalidade,
                            child: Text(modalidade.descricao),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _modalidade = value;
                  });
                },
                validator: (value) {
                  if (_modalidade == null) {
                    return 'Modalidade é obrigatória';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _dataCriacaoController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Data de Criação',
                  hintText: 'DD/MM/AAAA',
                ),
                keyboardType: TextInputType.datetime,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                  _DateInputFormatter(),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Data de criação é obrigatória';
                  } else if (value.length != 10) {
                    return 'Data inválida';
                  }
                  try {
                    final parts = value.split('/');
                    final day = int.parse(parts[0]);
                    final month = int.parse(parts[1]);
                    final year = int.parse(parts[2]);
                    final data = DateTime(year,month,day);

                    if (data.isAfter(DateTime.now())) {
                      return 'Data não pode ser futura';
                    }

                  } catch (e){
                    return 'Data inválida';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              CheckboxListTile(
                title: Text('Ativo'),
                value: _ativo,
                onChanged: (value) {
                  setState(() {
                    _ativo = value ?? false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _salvar() {
    if (_formKey.currentState!.validate()) {
      final parts = _dataCriacaoController.text.split('/');
      final dataCriacao = DateTime(
        int.parse(parts[2]),
        int.parse(parts[1]),
        int.parse(parts[0])
      );
      final disciplina = DisciplinaVo(
        id: _disciplina?.id,
        nome: _nomeController.text,
        curso: _curso!,
        modalidade: _modalidade!,
        dataCriacao: dataCriacao,
        ativo: _ativo
      );
      _repository.save(disciplina);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Disciplina salva com sucesso!'))
      );
      Navigator.of(context).pop();
    }
  }
}

class DisciplinaListPage extends StatefulWidget {
  const DisciplinaListPage({super.key});

  @override
  State<DisciplinaListPage> createState() => _DisciplinaListPageState();
}

class _DisciplinaListPageState extends State<DisciplinaListPage> {
  final DisciplinaRepository _repository = DisciplinaRepository();
  late List<DisciplinaVo> _disciplinas;

  @override
  void initState() {
    super.initState();
    _carregarDisciplinas();
  }

  void _carregarDisciplinas() {
    setState(() {
      _disciplinas = _repository.findAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listagem de Disciplians'),
        actions: [IconButton(onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => DisciplinaFormPage())
          ).then((_) => _carregarDisciplinas());
        }, icon: Icon(Icons.add_outlined))]
      ),
      body: _disciplinas.isEmpty ? Center(
        child: Text('Nenhuma disciplina cadastrado',
          style: Theme.of(context).textTheme.titleLarge
        )
      ) : ListView.builder(
            itemCount: _disciplinas.length,
            itemBuilder: (context, index) {
              return _buildDisciplinaTile(_disciplinas[index]);
            }
          )
    );
  }

  Widget _buildDisciplinaTile(DisciplinaVo disciplina) {
    return Dismissible(
      key: Key(disciplina.id),
      background: Container(
        color: Colors.blue,
        child: Center(
          child: Icon(Icons.edit_outlined, color: Colors.white)
        )
      ),
      secondaryBackground: Container(
        color: Colors.red,
        child: Center(
          child: Icon(Icons.delete_outlined, color: Colors.white)
        )
      ),
      child: ListTile(
        leading: Icon(
          Icons.auto_stories_outlined,
          size: 36,
        ),
        title: Text(disciplina.nome),
        subtitle: Text(disciplina.curso.descricao),
        trailing:
            disciplina.ativo
                ? const Icon(Icons.check_circle_outlined, color: Colors.green)
                : const Icon(Icons.cancel_outlined, color: Colors.red),
        onTap: () => _mostrarDetalhesDisciplina(disciplina),
      )
    );
  }

  void _mostrarDetalhesDisciplina(DisciplinaVo disciplina) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(disciplina.nome),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Curso: ${disciplina.curso.descricao}'),
              Text('Modalidade: ${disciplina.modalidade.descricao}'),
              Text(
                'Status: ${disciplina.ativo ? 'Disponível' : 'Indisponível'}',
              )
            ]
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}

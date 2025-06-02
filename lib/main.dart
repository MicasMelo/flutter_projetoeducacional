import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tarefa2/enums/curso_enum.dart';
import 'package:tarefa2/enums/modalidade_enum.dart';
import 'package:tarefa2/enums/sexo_enum.dart';
import 'package:tarefa2/exceptions/aluno_not_found_exception.dart';
import 'package:tarefa2/exceptions/disciplina_not_found_exception.dart';
import 'package:tarefa2/exceptions/professor_not_found_exception.dart';
import 'package:tarefa2/models/aluno_vo.dart';
import 'package:tarefa2/models/disciplina_vo.dart';
import 'package:tarefa2/models/professor_vo.dart';
import 'package:tarefa2/repositories/aluno_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tarefa2/repositories/disciplina_repository.dart';
import 'package:tarefa2/repositories/professor_repository.dart';
import 'package:tarefa2/utils/cpf_formatter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false, // Se quiser usar Material 3, pode por true
        scaffoldBackgroundColor: const Color(0xFF202123),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0E639C),
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        colorScheme: ColorScheme(
          brightness: Brightness.dark, // Define que é um tema escuro
          primary: Color.fromARGB(255, 78, 190, 255),
          onPrimary: Colors.white,
          secondary: Colors.grey,
          onSecondary: Colors.white,
          error: Colors.red,
          onError: Colors.white,
          surface: Color(0xFF2C2C2C),
          onSurface: Colors.white,
        ),

        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
        ),
      ),
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
        title: Text('Painel Acadêmico'),
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
  final String? professorId;

  const ProfessorFormPage({super.key, this.professorId});

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
  void initState() {
    super.initState();
    if (widget.alunoId != null) {
      // edição de aluno
      _carregarAluno();
    }
  }

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
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            constraints: BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
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
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(Duration(days: 365 * 16)),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _dataNascimentoController.text = 
                          "${pickedDate.day.toString().padLeft(2, '0')}/"
                          "${pickedDate.month.toString().padLeft(2, '0')}/"
                          "${pickedDate.year}";
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dataNascimentoController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Data de Nascimento',
                      hintText: 'DD/MM/AAAA',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Data de nascimento é obrigatória';
                      }

                      try {
                        final parts = value.split('/');
                        if (parts.length != 3) return 'Data inválida';

                        final day = int.parse(parts[0]);
                        final month = int.parse(parts[1]);
                        final year = int.parse(parts[2]);
                        final data = DateTime(year, month, day);

                        if (data.isAfter(DateTime.now())) {
                          return 'Data não pode ser do futuro';
                        }

                        int idade = DateTime.now().year - year;
                        if (DateTime.now().month < month ||
                            (DateTime.now().month == month && DateTime.now().day < day)) {
                          idade--;
                        }

                        if (idade < 16) {
                          return 'Aluno deve ter pelo menos 16 anos';
                        }

                      } catch (e) {
                        return 'Data inválida';
                      }

                      return null;
                    },
                  ),
                ),
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
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: _matriculado,
                        onChanged: (value) {
                          setState(() {
                            _matriculado = value!;
                          });
                        },
                      ),
                      Text('Matriculado'),
                    ],
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: _matriculado,
                        onChanged: (value) {
                          setState(() {
                            _matriculado = value!;
                          });
                        },
                      ),
                      Text('Não Matriculado'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )));
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

  void _carregarAluno() {
    try {
      _aluno = _repository.findById(widget.alunoId!);
      _raController.text = _aluno!.ra;
      _nomeCompletoController.text = _aluno!.nomeCompleto;
      _emailController.text = _aluno!.email;
      _dataNascimentoController.text =
          '${_aluno!.dataNascimento.day.toString().padLeft(2, '0')}/'
          '${_aluno!.dataNascimento.month.toString().padLeft(2, '0')}/'
          '${_aluno!.dataNascimento.year}';
      _sexo = _aluno!.sexo;
      _curso = _aluno!.curso;
      _matriculado = _aluno!.matriculado;
    } on AlunoNotFoundException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      Navigator.pop(context);
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
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // edição do aluno
          _editarAluno(aluno.id);
          return false;
        } else {
          return await showDialog(context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Confirma exclusão?'),
                content: Text('Deseja remover o aluno ${aluno.nomeCompleto}'),
                actions: [
                  TextButton(onPressed: () {
                    Navigator.of(context).pop(false);
                  }, child: Text('Cancelar')),
                  TextButton(onPressed: () {
                    Navigator.of(context).pop(true);
                  }, child: Text('Remover')),
                ],
              );
            },);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _removerAluno(aluno.id);
        }
      },
      child: ListTile(
        leading: Icon(
          Icons.person_outlined,
          color: aluno.sexo == SexoEnum.masculino ? Colors.blue : Colors.pinkAccent,
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

  void _editarAluno(String id) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => AlunoFormPage(alunoId: id)),
        )
        .then((_) => _carregarAlunos());
  }
  
  void _removerAluno(String id) {
    try {
      _repository.deleteById(id);
      _carregarAlunos();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aluno removido com sucesso'))
      );
    } on AlunoNotFoundException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }
}

class _ProfessorFormPageState extends State<ProfessorFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _repository = ProfessorRepository();

  final _cpfFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: { "#": RegExp(r'[0-9]') },
  );


  final _cpfController = TextEditingController();
  final _nomeCompletoController = TextEditingController();
  final _emailController = TextEditingController();
  final _dataNascimentoController = TextEditingController();

  SexoEnum? _sexo;
  CursoEnum? _curso;
  bool _ativo = false;

  ProfessorVo? _professor;

  @override
  void initState() {
    super.initState();
    if (widget.professorId != null) {
      _carregarProfessor();
    }
  }

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
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            constraints: BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
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
                  hintText: '123.456.789-00',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  _cpfFormatter,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'CPF é obrigatório';
                  } else if (!_cpfFormatter.isFill()) {
                    return 'CPF incompleto';
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
                  } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(Duration(days: 365 * 16)),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _dataNascimentoController.text = 
                          "${pickedDate.day.toString().padLeft(2, '0')}/"
                          "${pickedDate.month.toString().padLeft(2, '0')}/"
                          "${pickedDate.year}";
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dataNascimentoController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Data de Nascimento',
                      hintText: 'DD/MM/AAAA',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Data de nascimento é obrigatória';
                      }

                      try {
                        final parts = value.split('/');
                        if (parts.length != 3) return 'Data inválida';

                        final day = int.parse(parts[0]);
                        final month = int.parse(parts[1]);
                        final year = int.parse(parts[2]);
                        final data = DateTime(year, month, day);

                        if (data.isAfter(DateTime.now())) {
                          return 'Data não pode ser do futuro';
                        }

                        int idade = DateTime.now().year - year;
                        if (DateTime.now().month < month ||
                            (DateTime.now().month == month && DateTime.now().day < day)) {
                          idade--;
                        }

                        if (idade < 21) {
                          return 'Professor deve ter pelo menos 21 anos';
                        }

                      } catch (e) {
                        return 'Data inválida';
                      }

                      return null;
                    },
                  ),
                ),
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
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: _ativo,
                        onChanged: (value) {
                          setState(() {
                            _ativo = value!;
                          });
                        },
                      ),
                      Text('Ativo'),
                    ],
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: _ativo,
                        onChanged: (value) {
                          setState(() {
                            _ativo = value!;
                          });
                        },
                      ),
                      Text('Inativo'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )));
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

  void _carregarProfessor() {
    try {
      _professor = _repository.findById(widget.professorId!);
      _cpfController.text = CPFFormatter.format(_professor!.cpf);

      _nomeCompletoController.text = _professor!.nomeCompleto;
      _emailController.text = _professor!.email;
      _dataNascimentoController.text =
          '${_professor!.dataNascimento.day.toString().padLeft(2, '0')}/'
          '${_professor!.dataNascimento.month.toString().padLeft(2, '0')}/'
          '${_professor!.dataNascimento.year}';
      _sexo = _professor!.sexo;
      _curso = _professor!.curso;
      _ativo = _professor!.ativo;
    } on ProfessorNotFoundException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      Navigator.pop(context);
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
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _editarProfessor(professor.id);
          return false;
        } else {
          return await showDialog(context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Confirma exclusão?'),
                content: Text('Deseja remover o professor ${professor.nomeCompleto}'),
                actions: [
                  TextButton(onPressed: () {
                    Navigator.of(context).pop(false);
                  }, child: Text('Cancelar')),
                  TextButton(onPressed: () {
                    Navigator.of(context).pop(true);
                  }, child: Text('Remover')),
                ],
              );
            },);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _removerProfessor(professor.id);
        }
      },
      child: ListTile(
        leading: Icon(
          Icons.person_outlined,
          color: professor.sexo == SexoEnum.masculino ? Colors.blue : Colors.pinkAccent,
          size: 36,
        ),
        title: Text(professor.nomeCompleto),
        subtitle: Text(CPFFormatter.format(professor.cpf)),

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
              Text('CPF: ${CPFFormatter.format(professor.cpf)}'),
              Text('Área de Ensino: ${professor.curso.descricao}'),
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

  void _editarProfessor(String id) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => ProfessorFormPage(professorId: id)),
        )
        .then((_) => _carregarProfessores());
  }
  
  void _removerProfessor(String id) {
    try {
      _repository.deleteById(id);
      _carregarProfessores();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Professor removido com sucesso'))
      );
    } on ProfessorNotFoundException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
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
  void initState() {
    super.initState();
    if (widget.disciplinaId != null) {
      _carregarDisciplina();
    }
  }

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
        child: Center(
          child: Container(
            padding: EdgeInsets.all(20),
            constraints: BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
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
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().subtract(Duration(days: 365 * 16)),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _dataCriacaoController.text = 
                          "${pickedDate.day.toString().padLeft(2, '0')}/"
                          "${pickedDate.month.toString().padLeft(2, '0')}/"
                          "${pickedDate.year}";
                    });
                  }
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dataCriacaoController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Data de Lançamento',
                      hintText: 'DD/MM/AAAA',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Data do lançamento é obrigatória';
                      }

                      try {
                        final parts = value.split('/');
                        if (parts.length != 3) return 'Data inválida';

                        final day = int.parse(parts[0]);
                        final month = int.parse(parts[1]);
                        final year = int.parse(parts[2]);
                        final data = DateTime(year, month, day);

                        if (data.isAfter(DateTime.now())) {
                          return 'Data não pode ser do futuro';
                        }

                      } catch (e) {
                        return 'Data inválida';
                      }

                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Radio<bool>(
                        value: true,
                        groupValue: _ativo,
                        onChanged: (value) {
                          setState(() {
                            _ativo = value!;
                          });
                        },
                      ),
                      Text('Disponível'),
                    ],
                  ),
                  SizedBox(width: 20),
                  Row(
                    children: [
                      Radio<bool>(
                        value: false,
                        groupValue: _ativo,
                        onChanged: (value) {
                          setState(() {
                            _ativo = value!;
                          });
                        },
                      ),
                      Text('Indisponível'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )));
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

  void _carregarDisciplina() {
    try {
      _disciplina = _repository.findById(widget.disciplinaId!);
      _nomeController.text = _disciplina!.nome;
      _dataCriacaoController.text =
          '${_disciplina!.dataCriacao.day.toString().padLeft(2, '0')}/'
          '${_disciplina!.dataCriacao.month.toString().padLeft(2, '0')}/'
          '${_disciplina!.dataCriacao.year}';
      _curso = _disciplina!.curso;
      _modalidade = _disciplina!.modalidade;
      _ativo = _disciplina!.ativo;
    } on ProfessorNotFoundException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      Navigator.pop(context);
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
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _editarDisciplina(disciplina.id);
          return false;
        } else {
          return await showDialog(context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Confirma exclusão?'),
                content: Text('Deseja remover a disciplina ${disciplina.nome}'),
                actions: [
                  TextButton(onPressed: () {
                    Navigator.of(context).pop(false);
                  }, child: Text('Cancelar')),
                  TextButton(onPressed: () {
                    Navigator.of(context).pop(true);
                  }, child: Text('Remover')),
                ],
              );
            },);
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _removerDisciplina(disciplina.id);
        }
      },
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

  void _editarDisciplina(String id) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (context) => DisciplinaFormPage(disciplinaId: id)),
        )
        .then((_) => _carregarDisciplinas());
  }
  
  void _removerDisciplina(String id) {
    try {
      _repository.deleteById(id);
      _carregarDisciplinas();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Disciplina removida com sucesso'))
      );
    } on DisciplinaNotFoundException catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()))
      );
    }
  }
}

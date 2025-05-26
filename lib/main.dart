import 'package:tarefa2/enums/curso_enum.dart';
import 'package:tarefa2/enums/sexo_enum.dart';
import 'package:tarefa2/models/aluno_vo.dart';
import 'package:tarefa2/repositories/aluno_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// import 'exceptions/aluno_not_found_exception.dart';

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
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AlunoFormPage()),
              );
            },
            icon: Icon(Icons.add_outlined),
          ),
          IconButton(onPressed: () {
            Navigator.push(
              context, MaterialPageRoute(builder: (context) => AlunoListPage()));
          }, icon: Icon(Icons.list_outlined)),
        ],
      ),
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

class _AlunoFormPageState extends State<AlunoFormPage> {
  // chave/identificador global para o formulário do widget
  final _formKey = GlobalKey<FormState>();

  final _repository = AlunoRepository();

  final _raController = TextEditingController();
  final _nomeCompletoController = TextEditingController();
  final _emailController = TextEditingController();
  final _dataNascimentoController = TextEditingController();

  // preciso de outra forma para recuperar, no caso esses dois serão compobox
  SexoEnum? _sexo;
  CursoEnum? _curso; // usando underline _ para marcar que é privado
  bool _matriculado = false; // checkbox

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
                    return 'Noem deve possuir pelo menos 10 caracteres';
                  } else if (value.length > 50) {
                    return 'Noem deve ter até 50 caracteres';
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
                  _DateInputFormatter(), // vamos criar nossas própias formatações também
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Data de nascimento é obrigatório';
                  } else if (value.length != 10) {
                    return 'Data inválida';
                  }
                  try {
                    // "01/01/1990" = Datetime
                    // precisamos transformar split "01/01/1990" em ["01", "01", "1990"], outros pequenos vetores
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

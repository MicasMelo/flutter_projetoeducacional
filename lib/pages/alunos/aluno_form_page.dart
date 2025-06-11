import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tarefa2/enums/curso_enum.dart';
import 'package:tarefa2/enums/sexo_enum.dart';
import 'package:tarefa2/exceptions/aluno_not_found_exception.dart';
import 'package:tarefa2/models/aluno_vo.dart';
import 'package:tarefa2/repositories/aluno_repository.dart';

class AlunoFormPage extends StatefulWidget {
  //statefull porque vou precisar guardar dados
  final String? alunoId; // alunoId pode existir ou não (vira novo)

  // construtor
  const AlunoFormPage({super.key, this.alunoId});

  @override
  State<AlunoFormPage> createState() => _AlunoFormPageState();
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
                  DateTime initialDate = DateTime.now().subtract(Duration(days: 365 * 16));
                  if (_dataNascimentoController.text.isNotEmpty) {
                    try {
                      final parts = _dataNascimentoController.text.split('/');
                      if (parts.length == 3) {
                        final day = int.parse(parts[0]);
                        final month = int.parse(parts[1]);
                        final year = int.parse(parts[2]);
                        initialDate = DateTime(year, month, day);
                      }
                    } catch (_) {
                    }
                  }

                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    locale: const Locale('pt', 'BR'),
                    initialDate: initialDate,
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

  Future<void> _carregarAluno() async {
    try {
      final aluno = await _repository.findById(widget.alunoId!);
      setState(() {
        _aluno = aluno;
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
      });
    } on AlunoNotFoundException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar aluno: ${e.toString()}')),
      );
      Navigator.pop(context);
    }
  }
}
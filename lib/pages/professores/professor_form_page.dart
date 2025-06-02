import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:tarefa2/enums/curso_enum.dart';
import 'package:tarefa2/enums/sexo_enum.dart';
import 'package:tarefa2/exceptions/professor_not_found_exception.dart';
import 'package:tarefa2/models/professor_vo.dart';
import 'package:tarefa2/repositories/professor_repository.dart';
import 'package:tarefa2/utils/cpf_formatter.dart';

class ProfessorFormPage extends StatefulWidget {
  final String? professorId;

  const ProfessorFormPage({super.key, this.professorId});

  @override
  State<ProfessorFormPage> createState() => _ProfessorFormPageState();
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
import 'package:flutter/material.dart';
import 'package:tarefa2/enums/curso_enum.dart';
import 'package:tarefa2/enums/modalidade_enum.dart';
import 'package:tarefa2/exceptions/disciplina_not_found_exception.dart';
import 'package:tarefa2/models/disciplina_vo.dart';
import 'package:tarefa2/repositories/disciplina_repository.dart';

class DisciplinaFormPage extends StatefulWidget {
  final String? disciplinaId;

  const DisciplinaFormPage({super.key, this.disciplinaId});

  @override
  State<DisciplinaFormPage> createState() => _DisciplinaFormPageState();
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
                  DateTime initialDate = DateTime.now().subtract(Duration(days: 365 * 16));
                  if (_dataCriacaoController.text.isNotEmpty) {
                    try {
                      final parts = _dataCriacaoController.text.split('/');
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

  Future<void> _carregarDisciplina() async {
    try {
      final disciplina = await _repository.findById(widget.disciplinaId!);
      setState(() {
        _disciplina = disciplina;
        _nomeController.text = _disciplina!.nome;
        _dataCriacaoController.text =
            '${_disciplina!.dataCriacao.day.toString().padLeft(2, '0')}/'
            '${_disciplina!.dataCriacao.month.toString().padLeft(2, '0')}/'
            '${_disciplina!.dataCriacao.year}';
        _curso = _disciplina!.curso;
        _modalidade = _disciplina!.modalidade;
        _ativo = _disciplina!.ativo;
      });
    } on DisciplinaNotFoundException catch (e) {
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
        SnackBar(content: Text('Erro ao carregar disciplina: ${e.toString()}')),
      );
      Navigator.pop(context);
    }
  }
}
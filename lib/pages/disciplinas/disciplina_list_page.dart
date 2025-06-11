import 'package:flutter/material.dart';
import 'package:tarefa2/exceptions/disciplina_not_found_exception.dart';
import 'package:tarefa2/models/disciplina_vo.dart';
import 'package:tarefa2/pages/disciplinas/disciplina_form_page.dart';
import 'package:tarefa2/repositories/disciplina_repository.dart';

class DisciplinaListPage extends StatefulWidget {
  const DisciplinaListPage({super.key});

  @override
  State<DisciplinaListPage> createState() => _DisciplinaListPageState();
}

class _DisciplinaListPageState extends State<DisciplinaListPage> {
  final DisciplinaRepository _repository = DisciplinaRepository();
  
  List<DisciplinaVo> _disciplinas = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _carregarDisciplinas();
    });
  }

  Future<void> _carregarDisciplinas() async {
    try {
      final disciplinas = await _repository.findAll();
      if (!mounted) return;

      setState(() {
        _disciplinas = disciplinas;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar lista de disciplinas: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listagem de Disciplinas'),
        actions: [IconButton(onPressed: (){
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => DisciplinaFormPage())
          ).then((_) => _carregarDisciplinas());
        }, icon: Icon(Icons.add_outlined))]
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ClipRRect(
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
              child: _disciplinas.isEmpty ? Center(
                child: Text('Nenhuma disciplina cadastrado',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                )
              ) : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _disciplinas.length,
                    itemBuilder: (context, index) {
                      return _buildDisciplinaTile(_disciplinas[index]);
                    }
                  )
            ),
          ),
        ),
      ),
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
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

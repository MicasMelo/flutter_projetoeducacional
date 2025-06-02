import 'package:flutter/material.dart';
import 'package:tarefa2/enums/sexo_enum.dart';
import 'package:tarefa2/exceptions/professor_not_found_exception.dart';
import 'package:tarefa2/models/professor_vo.dart';
import 'package:tarefa2/pages/professores/professor_form_page.dart';
import 'package:tarefa2/repositories/professor_repository.dart';
import 'package:tarefa2/utils/cpf_formatter.dart';

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
              child: _professores.isEmpty ? Center(
                child: Text('Nenhum professor cadastrado',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                )
              ) : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _professores.length,
                    itemBuilder: (context, index) {
                      return _buildProfessorTile(_professores[index]);
                    }
                  )
            ),
          ),
        ),
      ),
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
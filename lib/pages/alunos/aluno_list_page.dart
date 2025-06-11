import 'package:flutter/material.dart';
import 'package:tarefa2/enums/sexo_enum.dart';
import 'package:tarefa2/exceptions/aluno_not_found_exception.dart';
import 'package:tarefa2/models/aluno_vo.dart';
import 'package:tarefa2/pages/alunos/aluno_form_page.dart';
import 'package:tarefa2/repositories/aluno_repository.dart';


class AlunoListPage extends StatefulWidget {
  const AlunoListPage({super.key});

  @override
  State<AlunoListPage> createState() => _AlunoListPageState();
}

class _AlunoListPageState extends State<AlunoListPage> {
  final AlunoRepository _repository = AlunoRepository();
  // late List<AlunoVo> _alunos;

  List<AlunoVo> _alunos = []; // Inicializa como lista vazia

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _carregarAlunos();
    });
  }

  Future<void> _carregarAlunos() async {
    try {
      final alunos = await _repository.findAll();
      if (!mounted) return;

      setState(() {
        _alunos = alunos;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao carregar lista de alunos: ${e.toString()}'),
        ),
      );
    }
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
              child: _alunos.isEmpty ? Center(
                child: Text('Nenhum aluno cadastrado',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
              ) : ListView.builder(
                    shrinkWrap: true, // importante para funcionar dentro do ScrollView
                    physics: NeverScrollableScrollPhysics(), // desativa o scroll interno
                    itemCount: _alunos.length,
                    itemBuilder: (context, index) {
                      return _buildAlunoTile(_alunos[index]);
                    },
                  ),
            ),
          ),
        ),
      ),
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
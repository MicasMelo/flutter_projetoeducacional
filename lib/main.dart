import 'package:tarefa2/pages/alunos/aluno_form_page.dart';
import 'package:tarefa2/pages/alunos/aluno_list_page.dart';
import 'package:tarefa2/pages/disciplinas/disciplina_form_page.dart';
import 'package:tarefa2/pages/disciplinas/disciplina_list_page.dart';
import 'package:tarefa2/pages/professores/professor_list_page.dart';
import 'package:tarefa2/pages/professores/professor_form_page.dart';
import 'package:flutter/material.dart';

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
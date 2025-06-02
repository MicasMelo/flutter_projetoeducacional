
class DisciplinaNotFoundException implements Exception {
  
  final String idOuValor;
  final bool isId;

  DisciplinaNotFoundException(this.idOuValor, {this.isId = true});

  @override
  String toString() {
    return isId
        ? 'ID da Disciplina [$idOuValor] não localizado'
        : 'Nome da Disciplina [$idOuValor] não localizado';
  }
}

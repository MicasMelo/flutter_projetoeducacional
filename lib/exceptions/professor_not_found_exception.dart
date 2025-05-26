// extends = herança de Classe
// implements = implementação de Interface
//        (contrato/assinaturas de métodos)

class ProfessorNotFoundException implements Exception {
  
  final String idOuValor;
  final bool isId;

  ProfessorNotFoundException(this.idOuValor, {this.isId = true});

  @override
  String toString() {
    return isId
        ? 'ID do Professor [$idOuValor] não localizado'
        : 'CPF ou Nome do Professor [$idOuValor] não localizado';
  }
}

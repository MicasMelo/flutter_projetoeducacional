enum ModalidadeEnum {
  presencial('Masculino'),
  adistancia('EAD'),
  hibrida('Híbrida');

  final String descricao;
  const ModalidadeEnum(this.descricao);
}
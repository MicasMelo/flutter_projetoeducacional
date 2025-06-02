class CPFFormatter {
  static String format(String cpf) {
    // Remove tudo que não for número
    final digits = cpf.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return cpf; // retorna como está se não válido

    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
  }
}

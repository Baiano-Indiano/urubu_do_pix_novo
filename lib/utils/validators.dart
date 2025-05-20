bool isValidEmail(String email) {
  final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,4}$');
  return emailRegex.hasMatch(email);
}

bool isValidCPF(String cpf) {
  final cpfNumeros = cpf.replaceAll(RegExp(r'[^0-9]'), '');
  if (cpfNumeros.length != 11) return false;
  if (RegExp(r'^(\d)\1{10}$').hasMatch(cpfNumeros)) return false;
  int soma = 0;
  for (int i = 0; i < 9; i++) {
    soma += int.parse(cpfNumeros[i]) * (10 - i);
  }
  int dig1 = 11 - (soma % 11);
  if (dig1 >= 10) dig1 = 0;
  if (dig1 != int.parse(cpfNumeros[9])) return false;
  soma = 0;
  for (int i = 0; i < 10; i++) {
    soma += int.parse(cpfNumeros[i]) * (11 - i);
  }
  int dig2 = 11 - (soma % 11);
  if (dig2 >= 10) dig2 = 0;
  if (dig2 != int.parse(cpfNumeros[10])) return false;
  return true;
}

bool isValidPhoneBR(String phone) {
  final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
  return cleaned.length >= 10 && cleaned.length <= 11 && !cleaned.startsWith('1');
}

bool isValidName(String name) {
  return RegExp(r"^[A-Za-zÀ-ÿ\s]{3,}").hasMatch(name.trim());
}

// Simulação: verifica se o e-mail já está cadastrado (stub, implementar no backend)
Future<bool> isEmailRegistered(String email) async {
  // Exemplo: sempre retorna false (não cadastrado)
  // Implemente chamada real ao backend se desejar
  await Future.delayed(const Duration(milliseconds: 100));
  return false;
}

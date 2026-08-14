import 'currency_formatter.dart';

class AppValidators {
  static String? Function(String?) required(String message) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Introduza o preço';
    }
    final parsed = AppCurrency.parse(value);
    if (parsed == null) {
      return 'Introduza um valor válido (ex.: 1500,00)';
    }
    if (parsed < 0) {
      return 'O preço não pode ser negativo';
    }
    return null;
  }

  static String? stock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Introduza a quantidade';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null) {
      return 'Introduza um número inteiro';
    }
    if (parsed < 0) {
      return 'A quantidade não pode ser negativa';
    }
    return null;
  }

  /// Telefone angolano: 9 dígitos, podendo vir com o indicativo +244.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Introduza o número de telefone';
    }
    var digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('244') && digits.length > 9) {
      digits = digits.substring(3);
    }
    if (digits.length != 9) {
      return 'O número deve ter 9 dígitos (ex.: 923 456 789)';
    }
    return null;
  }

  /// Email opcional: só valida o formato se o campo for preenchido.
  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final pattern = RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Email inválido';
    }
    return null;
  }

  /// NIF angolano: 9 a 14 caracteres alfanuméricos. Pessoa singular usa o nº do
  /// BI (ex.: 003456789LA042); empresa usa 9 ou 10 dígitos.
  static String? nif(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Introduza o NIF';
    }
    final clean = value.trim().replaceAll(' ', '').toUpperCase();
    if (!RegExp(r'^[A-Z0-9]{9,14}$').hasMatch(clean)) {
      return 'NIF inválido (9 a 14 caracteres)';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Introduza a senha';
    }
    if (value.length < 4) {
      return 'A senha deve ter pelo menos 4 caracteres';
    }
    return null;
  }
}

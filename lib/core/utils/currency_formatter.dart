/// Formatação do Kwanza angolano (AOA).
///
/// Em Angola o separador de milhares é o ponto e o separador decimal é a
/// vírgula, com o símbolo "Kz" depois do valor: `1.234,56 Kz`.
///
/// A formatação é feita à mão de propósito: não depende dos dados de locale do
/// `intl`, que precisariam de ser inicializados no arranque da aplicação.
class AppCurrency {
  static const String symbol = 'Kz';

  /// `1234.5` -> `1.234,50 Kz`
  static String format(num value) => '${formatPlain(value)} $symbol';

  /// `1234.5` -> `1.234,50` (sem símbolo, para tabelas e talões)
  static String formatPlain(num value) {
    final negative = value < 0;
    final fixed = value.abs().toStringAsFixed(2);
    final parts = fixed.split('.');
    final result = '${_groupThousands(parts[0])},${parts[1]}';
    return negative ? '-$result' : result;
  }

  /// `1234.5` -> `1.235 Kz` (sem casas decimais, para valores altos)
  static String formatCompact(num value) {
    final negative = value < 0;
    final rounded = value.abs().round().toString();
    final result = _groupThousands(rounded);
    return '${negative ? '-' : ''}$result $symbol';
  }

  /// Insere o ponto a cada três dígitos: `1234567` -> `1.234.567`
  static String _groupThousands(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Converte o texto escrito pelo utilizador num número.
  ///
  /// Aceita tanto `1234,56` (formato angolano) como `1234.56`, e ignora os
  /// pontos usados como separador de milhares.
  static double? parse(String? input) {
    if (input == null) return null;
    var text = input.trim().replaceAll(symbol, '').replaceAll(' ', '').trim();
    if (text.isEmpty) return null;

    final hasComma = text.contains(',');
    final hasDot = text.contains('.');

    if (hasComma && hasDot) {
      // "1.234,56" -> o ponto é separador de milhares
      text = text.replaceAll('.', '').replaceAll(',', '.');
    } else if (hasComma) {
      // "1234,56" -> a vírgula é o separador decimal
      text = text.replaceAll(',', '.');
    }

    return double.tryParse(text);
  }

  /// Texto para pré-preencher um campo de edição: `1234,56` (sem separador de
  /// milhares, para não atrapalhar a digitação).
  static String toInput(num value) =>
      value.toStringAsFixed(2).replaceAll('.', ',');
}

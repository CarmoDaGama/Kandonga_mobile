import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../../core/data/hive_database.dart';

/// Guarda a conta do comerciante no armazenamento local.
///
/// A aplicação funciona sem internet, por isso a conta vive só no aparelho. A
/// senha nunca é gravada em texto simples — guardamos apenas o resumo SHA-256
/// com um sal fixo, o suficiente para que quem abra o ficheiro do Hive não leia
/// a senha diretamente.
class AuthLocalStorage {
  static const _keyPasswordHash = 'auth_password_hash';
  static const _keyEmail = 'auth_email';
  static const _keyPhone = 'auth_phone';
  static const _keyLoggedIn = 'auth_logged_in';

  static const _salt = 'kandonga::v1';

  static String hashPassword(String password) {
    return sha256.convert(utf8.encode('$_salt$password')).toString();
  }

  /// Normaliza o telefone para comparação: só dígitos, sem indicativo +244.
  ///
  /// Assim "+244 923 456 789", "244923456789" e "923456789" são tratados como o
  /// mesmo número, que é o que o comerciante espera ao iniciar sessão.
  static String normalizePhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('244') && digits.length > 9) {
      digits = digits.substring(3);
    }
    return digits;
  }

  static String normalizeEmail(String email) => email.trim().toLowerCase();

  static bool get hasAccount =>
      HiveDatabase.settingsBox.get(_keyPasswordHash) != null;

  static bool get isLoggedIn =>
      HiveDatabase.settingsBox.get(_keyLoggedIn, defaultValue: false) == true;

  static String get savedEmail =>
      HiveDatabase.settingsBox.get(_keyEmail, defaultValue: '') as String;

  static String get savedPhone =>
      HiveDatabase.settingsBox.get(_keyPhone, defaultValue: '') as String;

  static Future<void> saveAccount({
    required String phone,
    required String email,
    required String password,
  }) async {
    final box = HiveDatabase.settingsBox;
    await box.put(_keyPhone, normalizePhone(phone));
    await box.put(_keyEmail, normalizeEmail(email));
    await box.put(_keyPasswordHash, hashPassword(password));
  }

  /// Atualiza o contacto quando o comerciante edita os detalhes da loja, para
  /// que ele possa continuar a iniciar sessão com o contacto novo.
  static Future<void> updateContacts({
    required String phone,
    required String email,
  }) async {
    if (!hasAccount) return;
    final box = HiveDatabase.settingsBox;
    await box.put(_keyPhone, normalizePhone(phone));
    await box.put(_keyEmail, normalizeEmail(email));
  }

  /// O identificador pode ser o email ou o número de telefone.
  static bool matchesIdentifier(String identifier) {
    final trimmed = identifier.trim();
    if (trimmed.isEmpty) return false;

    if (trimmed.contains('@')) {
      final email = savedEmail;
      return email.isNotEmpty && email == normalizeEmail(trimmed);
    }

    final phone = savedPhone;
    return phone.isNotEmpty && phone == normalizePhone(trimmed);
  }

  static bool matchesPassword(String password) {
    final stored = HiveDatabase.settingsBox.get(_keyPasswordHash);
    return stored != null && stored == hashPassword(password);
  }

  static Future<void> setLoggedIn(bool value) =>
      HiveDatabase.settingsBox.put(_keyLoggedIn, value);
}

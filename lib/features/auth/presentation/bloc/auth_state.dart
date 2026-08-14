import 'package:flutter/material.dart';

import '../../data/auth_local_storage.dart';

class AuthState extends ChangeNotifier {
  bool _isLoggedIn = AuthLocalStorage.isLoggedIn;

  bool get isLoggedIn => _isLoggedIn;

  /// Se já existe uma conta no aparelho, o ecrã inicial é o de entrar;
  /// caso contrário, o de criar conta.
  bool get hasAccount => AuthLocalStorage.hasAccount;

  /// Tenta iniciar sessão com email ou número de telefone.
  ///
  /// Devolve `null` em caso de sucesso, ou a mensagem de erro a mostrar.
  Future<String?> login(String identifier, String password) async {
    if (!AuthLocalStorage.hasAccount) {
      return 'Ainda não existe nenhuma conta neste aparelho. Crie a sua conta primeiro.';
    }
    if (!AuthLocalStorage.matchesIdentifier(identifier)) {
      return 'Não encontrámos nenhuma conta com esse email ou número de telefone.';
    }
    if (!AuthLocalStorage.matchesPassword(password)) {
      return 'Senha incorreta.';
    }

    await AuthLocalStorage.setLoggedIn(true);
    _isLoggedIn = true;
    notifyListeners();
    return null;
  }

  /// Cria a conta local. Os dados da loja são gravados à parte, pelo ShopBloc.
  Future<void> register({
    required String phone,
    required String email,
    required String password,
  }) async {
    await AuthLocalStorage.saveAccount(
      phone: phone,
      email: email,
      password: password,
    );
    await AuthLocalStorage.setLoggedIn(true);
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthLocalStorage.setLoggedIn(false);
    _isLoggedIn = false;
    notifyListeners();
  }
}

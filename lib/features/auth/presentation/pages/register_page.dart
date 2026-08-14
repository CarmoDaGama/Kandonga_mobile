import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../shop/domain/entities/shop.dart';
import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _nifController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nifController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Grava os dados da loja para aparecerem nos detalhes da loja e no talão.
    final shop = Shop(
      name: _nameController.text.trim(),
      addressLine1: _addressController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      nif: _nifController.text.trim().toUpperCase(),
      footerText: 'Obrigado pela preferência!',
    );
    context.read<ShopBloc>().add(UpdateShopEvent(shop));

    await context.read<AuthState>().register(
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left,
              size: 28, color: Theme.of(context).primaryColor),
          onPressed: () => context.go('/login'),
        ),
        title: const Text('Criar conta',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Estes dados aparecem nos detalhes da loja e nos talões que '
                  'entrega aos seus clientes.',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(height: 24),
                _field(
                  controller: _nameController,
                  label: 'Nome da loja ou nome pessoal',
                  hint: 'ex.: Mercearia Kandonga',
                  icon: Icons.storefront_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator:
                      AppValidators.required('Introduza o nome da loja'),
                ),
                _field(
                  controller: _addressController,
                  label: 'Endereço da loja',
                  hint: 'ex.: Rua Rainha Ginga nº 12, Luanda',
                  icon: Icons.location_on_outlined,
                  textCapitalization: TextCapitalization.words,
                  validator: AppValidators.required('Introduza o endereço'),
                ),
                _field(
                  controller: _phoneController,
                  label: 'Número de telefone',
                  hint: '923 456 789',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: AppValidators.phone,
                ),
                _field(
                  controller: _nifController,
                  label: 'NIF',
                  hint: 'ex.: 5417005550',
                  icon: Icons.badge_outlined,
                  textCapitalization: TextCapitalization.characters,
                  validator: AppValidators.nif,
                ),
                _field(
                  controller: _emailController,
                  label: 'Email (opcional)',
                  hint: 'ex.: geral@minhaloja.ao',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.optionalEmail,
                ),
                _field(
                  controller: _passwordController,
                  label: 'Senha',
                  hint: 'Mínimo 4 caracteres',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  validator: AppValidators.password,
                  suffix: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Vai entrar na aplicação com o seu email ou número de '
                  'telefone e esta senha.',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Criar conta',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Já tem conta?',
                        style:
                            TextStyle(fontSize: 14, color: Colors.grey[600])),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Entrar',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: suffix,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}

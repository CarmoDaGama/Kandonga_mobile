import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/shop.dart';
import '../bloc/shop_bloc.dart';
import '../../../auth/data/auth_local_storage.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';

class ShopDetailsPage extends StatefulWidget {
  const ShopDetailsPage({super.key});

  @override
  State<ShopDetailsPage> createState() => _ShopDetailsPageState();
}

class _ShopDetailsPageState extends State<ShopDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _address1Controller;
  late TextEditingController _address2Controller;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _nifController;
  late TextEditingController _footerController;

  bool _controllersFilled = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _nifController = TextEditingController();
    _footerController = TextEditingController();

    // Carrega os dados da loja
    context.read<ShopBloc>().add(LoadShopEvent());
  }

  void _updateControllers(Shop shop) {
    // Só preenche uma vez, para não apagar o que o utilizador está a escrever
    // quando o bloc reemite o estado.
    if (_controllersFilled) return;
    _controllersFilled = true;

    _nameController.text = shop.name;
    _address1Controller.text = shop.addressLine1;
    _address2Controller.text = shop.addressLine2;
    _phoneController.text = shop.phoneNumber;
    _emailController.text = shop.email;
    _nifController.text = shop.nif;
    _footerController.text = shop.footerText;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nifController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _saveShop() async {
    if (!_formKey.currentState!.validate()) return;

    final shop = Shop(
      name: _nameController.text.trim(),
      addressLine1: _address1Controller.text.trim(),
      addressLine2: _address2Controller.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim(),
      nif: _nifController.text.trim().toUpperCase(),
      footerText: _footerController.text.trim(),
    );

    // Mantém os dados de acesso alinhados: se mudar o telefone ou o email aqui,
    // passa a poder entrar com o contacto novo.
    await AuthLocalStorage.updateContacts(
      phone: shop.phoneNumber,
      email: shop.email,
    );

    if (!mounted) return;
    context.read<ShopBloc>().add(UpdateShopEvent(shop));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Detalhes da loja'),
        ),
        body: BlocConsumer<ShopBloc, ShopState>(
          listener: (context, state) {
            if (state is ShopLoaded) {
              _updateControllers(state.shop);
            } else if (state is ShopOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Detalhes da loja guardados!'),
                  backgroundColor: Colors.green));
              context.pop();
            } else if (state is ShopError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.message), backgroundColor: Colors.red));
            }
          },
          buildWhen: (previous, current) =>
              current is ShopLoading || current is ShopLoaded,
          builder: (context, state) {
            if (state is ShopLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('INFORMAÇÕES GERAIS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: AppTheme.primaryColor.withValues(alpha: 0.8),
                        )),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      'Estes dados aparecem nos talões digitais e impressos que '
                      'entrega aos seus clientes.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                    const SizedBox(height: 24),
                    const InputLabel(text: 'Nome da loja ou nome pessoal'),
                    _buildTextField(
                      controller: _nameController,
                      hint: 'ex.: Mercearia Kandonga',
                      validator:
                          AppValidators.required('Introduza o nome da loja'),
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Endereço da loja'),
                    _buildTextField(
                      controller: _address1Controller,
                      hint: 'ex.: Rua Rainha Ginga nº 12',
                      validator: AppValidators.required('Introduza o endereço'),
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Bairro / Município (opcional)'),
                    _buildTextField(
                      controller: _address2Controller,
                      hint: 'ex.: Ingombota, Luanda',
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Número de telefone'),
                    _buildTextField(
                      controller: _phoneController,
                      hint: '923 456 789',
                      keyboardType: TextInputType.phone,
                      textCapitalization: TextCapitalization.none,
                      validator: AppValidators.phone,
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'NIF'),
                    _buildTextField(
                      controller: _nifController,
                      hint: 'ex.: 5417005550',
                      textCapitalization: TextCapitalization.characters,
                      validator: AppValidators.nif,
                    ),
                    const SizedBox(height: 15),
                    const InputLabel(text: 'Email (opcional)'),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'ex.: geral@minhaloja.ao',
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      validator: AppValidators.optionalEmail,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const InputLabel(text: 'Mensagem no rodapé do talão'),
                        Text('Máx. 60 caracteres',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400])),
                      ],
                    ),
                    _buildTextField(
                      controller: _footerController,
                      hint: 'Obrigado pela preferência!',
                      maxLines: 2,
                      maxLength: 60,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _saveShop,
          icon: Icons.save,
          label: 'Guardar detalhes',
        ));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.words,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      textCapitalization: textCapitalization,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
      ),
    );
  }
}

import 'package:billing_app/core/widgets/input_label.dart';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../bloc/product_bloc.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/currency_formatter.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _barcode = '';
  double _price = 0.0;
  int _stock = 0;

  void _scanBarcode() async {
    final result = await context.push<String>('/scanner');
    if (result != null && result.isNotEmpty) {
      setState(() {
        _barcode = result;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final productState = context.read<ProductBloc>().state;
      final existingProduct =
          productState.products.where((p) => p.barcode == _barcode).firstOrNull;

      if (existingProduct != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Já existe um produto com o código de barras "$_barcode".'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final product = Product(
        id: const Uuid().v4(),
        name: _name,
        barcode: _barcode,
        price: _price,
        stock: _stock,
      );

      context.read<ProductBloc>().add(AddProduct(product));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left,
                size: 28, color: Theme.of(context).primaryColor),
            onPressed: () => context.pop(),
          ),
          title: const Text('Adicionar produto',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const InputLabel(text: 'Código de barras'),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          key: ValueKey(_barcode),
                          initialValue: _barcode,
                          decoration: const InputDecoration(
                            hintText: 'Leia ou escreva o código de barras',
                          ),
                          validator: AppValidators.required(
                              'Introduza o código de barras'),
                          onSaved: (value) => _barcode = value!,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.qr_code_scanner,
                              color: AppTheme.primaryColor),
                          onPressed: _scanBarcode,
                          padding: const EdgeInsets.all(14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text('Toque no ícone para abrir a câmara',
                      style: TextStyle(fontSize: 12, color: Color(0xFF4C669A))),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Nome do produto'),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: 'ex.: Arroz 1kg',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: AppValidators.required('Introduza o nome'),
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Preço'),
                  TextFormField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      hintText: '0,00',
                      suffixText: AppCurrency.symbol,
                      suffixStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black),
                    ),
                    validator: AppValidators.price,
                    onSaved: (value) => _price = AppCurrency.parse(value) ?? 0,
                  ),
                  const SizedBox(height: 24),
                  const InputLabel(text: 'Quantidade inicial em stock'),
                  TextFormField(
                    initialValue: '0',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: 'ex.: 10',
                    ),
                    validator: AppValidators.stock,
                    onSaved: (value) => _stock = int.parse(value!.trim()),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: PrimaryButton(
          onPressed: _submit,
          icon: Icons.add_circle,
          label: 'Adicionar produto',
        ));
  }
}

import 'package:equatable/equatable.dart';

class Shop extends Equatable {
  /// Nome da loja ou do comerciante. Obrigatório.
  final String name;

  /// Endereço da loja. Obrigatório.
  final String addressLine1;

  /// Complemento do endereço (bairro, município). Opcional.
  final String addressLine2;

  /// Número de telefone. Obrigatório.
  final String phoneNumber;

  /// Email. Opcional.
  final String email;

  /// Número de Identificação Fiscal. Obrigatório — sai no talão por exigência
  /// da AGT.
  final String nif;

  /// Mensagem no rodapé do talão. Opcional.
  final String footerText;

  const Shop({
    this.name = '',
    this.addressLine1 = '',
    this.addressLine2 = '',
    this.phoneNumber = '',
    this.email = '',
    this.nif = '',
    this.footerText = '',
  });

  Shop copyWith({
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? phoneNumber,
    String? email,
    String? nif,
    String? footerText,
  }) {
    return Shop(
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      nif: nif ?? this.nif,
      footerText: footerText ?? this.footerText,
    );
  }

  /// Endereço completo numa linha, para talões e cabeçalhos.
  String get fullAddress => addressLine2.trim().isEmpty
      ? addressLine1
      : '$addressLine1, $addressLine2';

  @override
  List<Object?> get props =>
      [name, addressLine1, addressLine2, phoneNumber, email, nif, footerText];
}

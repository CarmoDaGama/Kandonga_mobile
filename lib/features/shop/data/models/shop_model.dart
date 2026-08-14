import 'package:hive/hive.dart';
import '../../domain/entities/shop.dart';

part 'shop_model.g.dart';

@HiveType(typeId: 1)
class ShopModel extends Shop {
  @override
  @HiveField(0)
  final String name;
  @override
  @HiveField(1)
  final String addressLine1;
  @override
  @HiveField(2)
  final String addressLine2;
  @override
  @HiveField(3)
  final String phoneNumber;
  // O índice 4 era o "upiId" (sistema de pagamentos indiano) e foi retirado.
  // Não voltar a usá-lo: registos antigos ainda o contêm.
  @override
  @HiveField(5)
  final String footerText;
  @override
  @HiveField(6)
  final String email;
  @override
  @HiveField(7)
  final String nif;

  const ShopModel({
    required this.name,
    required this.addressLine1,
    required this.addressLine2,
    required this.phoneNumber,
    required this.footerText,
    this.email = '',
    this.nif = '',
  }) : super(
          name: name,
          addressLine1: addressLine1,
          addressLine2: addressLine2,
          phoneNumber: phoneNumber,
          email: email,
          nif: nif,
          footerText: footerText,
        );

  factory ShopModel.fromEntity(Shop shop) {
    return ShopModel(
      name: shop.name,
      addressLine1: shop.addressLine1,
      addressLine2: shop.addressLine2,
      phoneNumber: shop.phoneNumber,
      email: shop.email,
      nif: shop.nif,
      footerText: shop.footerText,
    );
  }

  Shop toEntity() => this;
}

import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/shop_repository.dart';
import '../models/shop_model.dart';

class ShopRepositoryImpl implements ShopRepository {
  static const String shopKey = 'shop_details';

  @override
  Future<Either<Failure, Shop>> getShop() async {
    try {
      final box = HiveDatabase.shopBox;

      ShopModel? shop;
      try {
        shop = box.get(shopKey);
      } catch (_) {
        // Registo gravado com um esquema antigo (por exemplo, antes do NIF).
        // Descarta-o para a loja ser preenchida de novo em vez de rebentar.
        await box.delete(shopKey);
        shop = null;
      }

      // Sem loja gravada devolvemos uma loja vazia: os dados reais entram no
      // cadastro ou no ecrã de detalhes da loja.
      return Right(shop ?? const Shop());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateShop(Shop shop) async {
    try {
      final box = HiveDatabase.shopBox;
      final model = ShopModel.fromEntity(shop);
      await box.put(shopKey, model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}

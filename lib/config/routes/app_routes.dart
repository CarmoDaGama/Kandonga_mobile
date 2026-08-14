import 'package:go_router/go_router.dart';
import '../../features/auth/data/auth_local_storage.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/billing/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/presentation/pages/add_product_page.dart';
import '../../features/product/presentation/pages/edit_product_page.dart';
import '../../features/shop/presentation/pages/shop_details_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/menu_page.dart';
import '../../features/billing/presentation/pages/scanner_page.dart';
import '../../features/billing/presentation/pages/checkout_page.dart';
import '../../features/accounting/presentation/pages/accounting_page.dart';
import '../../features/accounting/presentation/pages/credit_score_page.dart';
import '../../features/product/domain/entities/product.dart';

/// Onde a aplicação abre:
/// - sessão iniciada       -> ecrã principal
/// - já existe uma conta   -> entrar
/// - primeira utilização   -> criar conta
String _initialLocation() {
  if (AuthLocalStorage.isLoggedIn) return '/';
  if (AuthLocalStorage.hasAccount) return '/login';
  return '/register';
}

final router = GoRouter(
  initialLocation: _initialLocation(),
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'scanner',
          builder: (context, state) => const ScannerPage(),
        ),
        GoRoute(
          path: 'checkout',
          builder: (context, state) => const CheckoutPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const MenuPage(),
    ),
    GoRoute(
      path: '/accounting',
      builder: (context, state) => const AccountingPage(),
    ),
    GoRoute(
      path: '/credit-score',
      builder: (context, state) => const CreditScorePage(),
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddProductPage(),
        ),
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) {
            final product = state.extra as Product?;
            if (product == null) {
              return const ProductListPage();
            }
            return EditProductPage(product: product);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => const ShopDetailsPage(),
    ),
  ],
);
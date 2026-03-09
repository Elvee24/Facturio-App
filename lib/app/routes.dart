import 'package:go_router/go_router.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/clientes/presentation/pages/clientes_list_page.dart';
import '../features/clientes/presentation/pages/cliente_form_page.dart';
import '../features/produtos/presentation/pages/produtos_list_page.dart';
import '../features/produtos/presentation/pages/produto_form_page.dart';
import '../features/faturas/presentation/pages/faturas_list_page.dart';
import '../features/faturas/presentation/pages/fatura_form_page.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String clientes = '/clientes';
  static const String clienteForm = '/clientes/form';
  static const String produtos = '/produtos';
  static const String produtoForm = '/produtos/form';
  static const String faturas = '/faturas';
  static const String faturaForm = '/faturas/form';

  static final GoRouter router = GoRouter(
    initialLocation: dashboard,
    routes: [
      GoRoute(
        path: dashboard,
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: clientes,
        builder: (context, state) => const ClientesListPage(),
      ),
      GoRoute(
        path: clienteForm,
        builder: (context, state) {
          final clienteId = state.uri.queryParameters['id'];
          return ClienteFormPage(clienteId: clienteId);
        },
      ),
      GoRoute(
        path: produtos,
        builder: (context, state) => const ProdutosListPage(),
      ),
      GoRoute(
        path: produtoForm,
        builder: (context, state) {
          final produtoId = state.uri.queryParameters['id'];
          return ProdutoFormPage(produtoId: produtoId);
        },
      ),
      GoRoute(
        path: faturas,
        builder: (context, state) => const FaturasListPage(),
      ),
      GoRoute(
        path: faturaForm,
        builder: (context, state) {
          final faturaId = state.uri.queryParameters['id'];
          return FaturaFormPage(faturaId: faturaId);
        },
      ),
    ],
  );
}

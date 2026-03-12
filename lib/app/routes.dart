import 'package:go_router/go_router.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/clientes/presentation/pages/clientes_list_page.dart';
import '../features/clientes/presentation/pages/cliente_form_page.dart';
import '../features/produtos/presentation/pages/produtos_list_page.dart';
import '../features/produtos/presentation/pages/produto_form_page.dart';
import '../features/faturas/presentation/pages/faturas_list_page.dart';
import '../features/faturas/presentation/pages/fatura_form_page.dart';
import '../features/faturas/presentation/pages/fatura_detail_page.dart';
import '../features/configuracoes/presentation/pages/configuracoes_page.dart';
import '../features/tutorial/presentation/pages/tutorial_page.dart';
import '../features/personalizacao/presentation/pages/personalizacao_page.dart';
import '../features/sobre/presentation/pages/licenca_page.dart';

class AppRoutes {
  static const String splash = '/';
  static const String tutorial = '/tutorial';
  static const String dashboard = '/dashboard';
  static const String clientes = '/clientes';
  static const String clienteForm = '/clientes/form';
  static const String produtos = '/produtos';
  static const String produtoForm = '/produtos/form';
  static const String faturas = '/faturas';
  static const String faturaForm = '/faturas/form';
  static const String faturaDetail = '/faturas/detail';
  static const String configuracoes = '/configuracoes';
  static const String personalizacao = '/personalizacao';
  static const String licenca = '/licenca';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: tutorial,
        builder: (context, state) => const TutorialPage(),
      ),
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
      GoRoute(
        path: faturaDetail,
        builder: (context, state) {
          final faturaId = state.uri.queryParameters['id'];
          if (faturaId == null) {
            throw Exception('ID da fatura é obrigatório');
          }
          return FaturaDetailPage(faturaId: faturaId);
        },
      ),
      GoRoute(
        path: configuracoes,
        builder: (context, state) => const ConfiguracoesPage(),
      ),
      GoRoute(
        path: personalizacao,
        builder: (context, state) => const PersonalizacaoPage(),
      ),
      GoRoute(
        path: licenca,
        builder: (context, state) => const LicencaPage(),
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/i18n/app_text.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/models/configuracao_empresa.dart';
import '../../../../core/services/admin_auth_service.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/fatura_legal_service.dart';
import '../../../../core/services/tutorial_service.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../app/routes.dart';
import '../providers/configuracoes_provider.dart';

class ConfiguracoesPage extends ConsumerStatefulWidget {
  const ConfiguracoesPage({super.key});

  @override
  ConsumerState<ConfiguracoesPage> createState() => _ConfiguracoesPageState();
}

class _ConfiguracoesPageState extends ConsumerState<ConfiguracoesPage> 
    with SingleTickerProviderStateMixin {
  final _nomeEmpresaController = TextEditingController();
  final _itemController = TextEditingController();
  final _nifController = TextEditingController();
  final _moradaController = TextEditingController();
  final _codigoPostalController = TextEditingController();
  final _localidadeController = TextEditingController();
  final _paisController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _caeController = TextEditingController();
  final _capitalSocialController = TextEditingController();
  final _conservatoriaController = TextEditingController();
  final _numeroRegistoComercialController = TextEditingController();
  final _numeroChaveCertificacaoATController = TextEditingController();
  final _codigoValidacaoSoftwareATController = TextEditingController();
  final _serieAtualController = TextEditingController();

  late TabController _tabController;
  List<double> _ivaOptions = [];
  List<String> _unidades = [];
  List<String> _estadosFatura = [];
  List<String> _meiosPagamento = [];
  List<String> _tiposDocumento = [];
  String _adminPinHash = AdminAuthService.defaultPinHash;
  bool _inicializado = false;

  String _t(BuildContext context, {required String pt, required String en}) {
    return AppText.tr(context, pt: pt, en: en);
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nomeEmpresaController.dispose();
    _itemController.dispose();
    _nifController.dispose();
    _moradaController.dispose();
    _codigoPostalController.dispose();
    _localidadeController.dispose();
    _paisController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _caeController.dispose();
    _capitalSocialController.dispose();
    _conservatoriaController.dispose();
    _numeroRegistoComercialController.dispose();
    _numeroChaveCertificacaoATController.dispose();
    _codigoValidacaoSoftwareATController.dispose();
    _serieAtualController.dispose();
    super.dispose();
  }

  void _carregarEmMemoria(ConfiguracaoEmpresa cfg) {
    if (_inicializado) return;
    _nomeEmpresaController.text = cfg.nomeEmpresa;
    _nifController.text = cfg.nif;
    _moradaController.text = cfg.morada;
    _codigoPostalController.text = cfg.codigoPostal;
    _localidadeController.text = cfg.localidade;
    _paisController.text = cfg.pais;
    _emailController.text = cfg.email ?? '';
    _telefoneController.text = cfg.telefone ?? '';
    _caeController.text = cfg.cae ?? '';
    _capitalSocialController.text = cfg.capitalSocial ?? '';
    _conservatoriaController.text = cfg.conservatoria ?? '';
    _numeroRegistoComercialController.text = cfg.numeroRegistoComercial ?? '';
    _numeroChaveCertificacaoATController.text = cfg.numeroChaveCertificacaoAT ?? '';
    _codigoValidacaoSoftwareATController.text = cfg.codigoValidacaoSoftwareAT ?? '';
    _serieAtualController.text = cfg.serieAtual;
    _ivaOptions = [...cfg.ivaOptions]..sort();
    _unidades = [...cfg.unidades];
    _estadosFatura = [...cfg.estadosFatura];
    _meiosPagamento = [...cfg.meiosPagamento];
    _tiposDocumento = [...cfg.tiposDocumento];
    _adminPinHash = cfg.adminPinHash;
    _inicializado = true;
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeProvider); // rebuild on language change
    final colors = Theme.of(context).colorScheme;
    final configAsync = ref.watch(configuracoesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(context, pt: 'Configurações da Empresa', en: 'Company Settings')),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(icon: const Icon(Icons.business), text: _t(context, pt: 'Dados Básicos', en: 'Basic Data')),
            Tab(icon: const Icon(Icons.location_on), text: _t(context, pt: 'Dados Fiscais', en: 'Tax Data')),
            Tab(icon: const Icon(Icons.verified_user), text: _t(context, pt: 'Certificação AT', en: 'Tax Authority Certification')),
            Tab(icon: const Icon(Icons.description), text: _t(context, pt: 'Documentos', en: 'Documents')),
          ],
        ),
      ),
      body: configAsync.when(
        data: (cfg) {
          _carregarEmMemoria(cfg);

          return TabBarView(
            controller: _tabController,
            children: [
              _buildDadosBasicosTab(context, colors, cfg),
              _buildDadosFiscaisTab(context, colors),
              _buildCertificacaoATTab(context, colors),
              _buildDocumentosTab(context, colors, cfg),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${_t(context, pt: 'Erro ao carregar configurações', en: 'Error loading settings')}: $e')),
      ),
    );
  }

  // Aba 1: Dados Básicos
  Widget _buildDadosBasicosTab(BuildContext context, ColorScheme colors, ConfiguracaoEmpresa cfg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primary, colors.secondary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t(context, pt: 'Personalização da aplicação', en: 'Application Customization'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _t(context, pt: 'Defina as opções visíveis em produtos e faturas.', en: 'Set options shown in products and invoices.'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _t(context, pt: 'Nome da empresa', en: 'Company Name'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nomeEmpresaController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'Nome exibido na aplicação', en: 'Name displayed in the app'),
                      prefixIcon: const Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _secaoLista(
                    titulo: _t(context, pt: 'Taxas de IVA disponíveis', en: 'Available VAT rates'),
                    dica: _t(context, pt: 'Exemplo: 23 ou 6', en: 'Example: 23 or 6'),
                    chips: _ivaOptions.map((e) => '${e.toStringAsFixed(0)}%').toList(),
                    onAdicionar: _adicionarIva,
                    onRemover: (index) {
                      if (_ivaOptions.length <= 1) return;
                      setState(() => _ivaOptions.removeAt(index));
                    },
                  ),
                  const SizedBox(height: 16),
                  _secaoLista(
                    titulo: _t(context, pt: 'Unidades disponíveis', en: 'Available units'),
                    dica: _t(context, pt: 'Exemplo: un, kg, h', en: 'Example: pc, kg, h'),
                    chips: _unidades,
                    onAdicionar: _adicionarTextoUnidade,
                    onRemover: (index) {
                      if (_unidades.length <= 1) return;
                      setState(() => _unidades.removeAt(index));
                    },
                  ),
                  const SizedBox(height: 16),
                  _secaoLista(
                    titulo: _t(context, pt: 'Estados de fatura disponíveis', en: 'Available invoice statuses'),
                    dica: _t(context, pt: 'Exemplo: emitida, paga', en: 'Example: issued, paid'),
                    chips: _estadosFatura,
                    onAdicionar: _adicionarTextoEstado,
                    onRemover: (index) {
                      if (_estadosFatura.length <= 1) return;
                      setState(() => _estadosFatura.removeAt(index));
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _t(context, pt: 'Ajuda e Tutorial', en: 'Help and Tutorial'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.blue.shade50,
                    child: ListTile(
                      leading: Icon(Icons.help_outline, color: colors.primary),
                          title: Text(_t(context, pt: 'Tutorial de boas-vindas', en: 'Welcome Tutorial')),
                      subtitle: Text(
                        TutorialService.isTutorialCompleted()
                            ? _t(context, pt: 'Tutorial já visualizado', en: 'Tutorial already viewed')
                            : _t(context, pt: 'Tutorial não visualizado', en: 'Tutorial not viewed yet'),
                      ),
                      trailing: ElevatedButton.icon(
                        onPressed: () async {
                          await TutorialService.resetTutorial();
                          if (context.mounted) {
                            UiHelpers.mostrarSnackBar(
                              context,
                              mensagem: _t(context, pt: 'Tutorial reiniciado. A redirecionar...', en: 'Tutorial reset. Redirecting...'),
                              tipo: TipoSnackBar.sucesso,
                            );
                            await Future.delayed(const Duration(milliseconds: 500));
                            if (context.mounted) {
                              Navigator.pushNamed(context, AppRoutes.tutorial);
                            }
                          }
                        },
                        icon: const Icon(Icons.replay, size: 18),
                        label: Text(_t(context, pt: 'Ver Tutorial', en: 'Open Tutorial')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _t(context, pt: 'Personalização', en: 'Customization'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Card(
                    color: Colors.purple.shade50,
                    child: ListTile(
                      leading: Icon(Icons.palette, color: colors.primary),
                      title: Text(_t(context, pt: 'Tema e Aparência', en: 'Theme and Appearance')),
                      subtitle: Text(_t(context, pt: 'Personalize cores, ícones e muito mais', en: 'Customize colors, icons, and more')),
                      trailing: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.personalizacao);
                        },
                        icon: const Icon(Icons.tune, size: 18),
                        label: Text(_t(context, pt: 'Personalizar', en: 'Customize')),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _t(context, pt: 'Segurança', en: 'Security'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.lock_reset),
                    title: Text(_t(context, pt: 'Alterar PIN de administrador', en: 'Change administrator PIN')),
                    subtitle: Text(_t(context, pt: 'Este PIN protege o acesso às configurações.', en: 'This PIN protects access to settings.')),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _alterarPin,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _salvar(cfg),
                    icon: const Icon(Icons.save),
                    label: Text(_t(context, pt: 'Guardar alterações', en: 'Save changes')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Aba 2: Dados Fiscais
  Widget _buildDadosFiscaisTab(BuildContext context, ColorScheme colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primary, colors.secondary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t(context, pt: 'Dados Fiscais da Empresa', en: 'Company Tax Data'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _t(context, pt: 'Informação obrigatória para faturas legais.', en: 'Mandatory information for legal invoices.'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nifController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'NIF *', en: 'Tax ID *'),
                      prefixIcon: const Icon(Icons.badge),
                      helperText: _t(context, pt: 'Número de Identificação Fiscal (9 dígitos)', en: 'Tax identification number (9 digits)'),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 9,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _moradaController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'Morada *', en: 'Address *'),
                      prefixIcon: const Icon(Icons.home),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codigoPostalController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'Código Postal *', en: 'Postal Code *'),
                      prefixIcon: const Icon(Icons.markunread_mailbox),
                      helperText: _t(context, pt: 'Formato: XXXX-XXX', en: 'Format: XXXX-XXX'),
                    ),
                    maxLength: 8,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _localidadeController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'Localidade *', en: 'City *'),
                      prefixIcon: const Icon(Icons.location_city),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _paisController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'País *', en: 'Country *'),
                      prefixIcon: const Icon(Icons.flag),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'Email', en: 'Email'),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _telefoneController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'Telefone', en: 'Phone'),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _caeController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'CAE (Código de Atividade Económica)', en: 'Economic Activity Code'),
                      prefixIcon: const Icon(Icons.work),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _capitalSocialController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'Capital Social', en: 'Share Capital'),
                      prefixIcon: const Icon(Icons.euro),
                      helperText: _t(context, pt: 'Exemplo: 5000,00 EUR', en: 'Example: 5000.00 EUR'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _conservatoriaController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'Conservatória do Registo Comercial', en: 'Commercial Registry Office'),
                      prefixIcon: const Icon(Icons.account_balance),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _numeroRegistoComercialController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'Número do Registo Comercial', en: 'Commercial Registration Number'),
                      prefixIcon: const Icon(Icons.numbers),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Aba 3: Certificação AT
  Widget _buildCertificacaoATTab(BuildContext context, ColorScheme colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primary, colors.secondary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t(context, pt: 'Certificação AT', en: 'Tax Authority Certification'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _t(context, pt: 'Chaves de certificação da Autoridade Tributária.', en: 'Certification keys from the tax authority.'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _t(
                        context,
                        pt: 'AVISO: Para uso em produção, é obrigatório obter certificação oficial da AT. Os códigos ATCUD gerados atualmente são simulados.',
                        en: 'WARNING: For production use, official tax authority certification is mandatory. Current ATCUD codes are simulated.',
                      ),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _numeroChaveCertificacaoATController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'Número da Chave de Certificação AT', en: 'Tax Certification Key Number'),
                      prefixIcon: const Icon(Icons.vpn_key),
                      helperText: _t(context, pt: 'Fornecido pela Autoridade Tributária', en: 'Provided by the tax authority'),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _codigoValidacaoSoftwareATController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'Código de Validação do Software AT', en: 'Tax Software Validation Code'),
                      prefixIcon: const Icon(Icons.security),
                      helperText: _t(context, pt: 'Código obtido após certificação do software', en: 'Code obtained after software certification'),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.info_outline),
                    title: Text(_t(context, pt: 'Como obter certificação?', en: 'How to obtain certification?')),
                    subtitle: Text(_t(context, pt: 'Contacte a AT em www.portaldasfinancas.gov.pt', en: 'Contact the tax authority at www.portaldasfinancas.gov.pt')),
                    onTap: () {
                      UiHelpers.mostrarSnackBar(
                        context,
                        mensagem: _t(context, pt: 'Aceda ao Portal das Finanças para informações sobre certificação de software.', en: 'Open the tax portal for software certification details.'),
                        tipo: TipoSnackBar.info,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Aba 4: Documentos
  Widget _buildDocumentosTab(BuildContext context, ColorScheme colors, ConfiguracaoEmpresa cfg) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.primary, colors.secondary],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t(context, pt: 'Documentos e Séries', en: 'Documents and Series'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.onPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  _t(context, pt: 'Configure tipos de documento, meios de pagamento e séries.', en: 'Configure document types, payment methods, and series.'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onPrimary.withValues(alpha: 0.9),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _secaoLista(
                    titulo: _t(context, pt: 'Meios de Pagamento', en: 'Payment Methods'),
                    dica: _t(context, pt: 'Exemplo: Numerário, MB Way', en: 'Example: Cash, MB Way'),
                    chips: _meiosPagamento,
                    onAdicionar: _adicionarMeioPagamento,
                    onRemover: (index) {
                      if (_meiosPagamento.length <= 1) return;
                      setState(() => _meiosPagamento.removeAt(index));
                    },
                  ),
                  const SizedBox(height: 16),
                  _secaoLista(
                    titulo: _t(context, pt: 'Tipos de Documento', en: 'Document Types'),
                    dica: _t(context, pt: 'Exemplo: Fatura, Nota de Crédito', en: 'Example: Invoice, Credit Note'),
                    chips: _tiposDocumento,
                    onAdicionar: _adicionarTipoDocumento,
                    onRemover: (index) {
                      if (_tiposDocumento.length <= 1) return;
                      setState(() => _tiposDocumento.removeAt(index));
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _serieAtualController,
                    decoration: InputDecoration(
                      labelText: _t(context, pt: 'Série Atual *', en: 'Current Series *'),
                      prefixIcon: const Icon(Icons.format_list_numbered),
                      helperText: _t(context, pt: 'Série a usar nos novos documentos (ex: A, 2024, FT)', en: 'Series for new documents (e.g., A, 2024, FT)'),
                    ),
                    maxLength: 10,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _salvar(cfg),
                    icon: const Icon(Icons.save),
                    label: Text(_t(context, pt: 'Guardar alterações', en: 'Save changes')),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _t(context, pt: 'Configurações de Backup', en: 'Backup Settings'),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.folder),
                    title: Text(
                      _t(context, pt: 'Diretório de Backup', en: 'Backup Directory'),
                    ),
                    subtitle: Text(
                      cfg.diretorioBackup ?? _t(context, pt: 'Padrão (Downloads)', en: 'Default (Downloads)'),
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _mudarDiretorioBackup(cfg),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _secaoLista({
    required String titulo,
    required String dica,
    required List<String> chips,
    required Future<void> Function() onAdicionar,
    required void Function(int index) onRemover,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (int i = 0; i < chips.length; i++)
              InputChip(
                label: Text(chips[i]),
                onDeleted: () => onRemover(i),
              ),
            ActionChip(
              avatar: const Icon(Icons.add, size: 18),
              label: Text('${_t(context, pt: 'Adicionar', en: 'Add')} ($dica)'),
              onPressed: onAdicionar,
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _adicionarIva() async {
    _itemController.clear();
    final valor = await _mostrarDialogoInput(
      titulo: _t(context, pt: 'Adicionar taxa de IVA', en: 'Add VAT rate'),
      label: _t(context, pt: 'Taxa (ex.: 23)', en: 'Rate (e.g., 23)'),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
    if (valor == null) return;

    final parsed = double.tryParse(valor.replaceAll(',', '.'));
    if (parsed == null || parsed < 0 || parsed > 100) {
      if (mounted) {
        UiHelpers.mostrarSnackBar(
          context,
          mensagem: _t(context, pt: 'Valor de IVA inválido. Use um número entre 0 e 100.', en: 'Invalid VAT value. Use a number between 0 and 100.'),
          tipo: TipoSnackBar.aviso,
        );
      }
      return;
    }

    if (_ivaOptions.contains(parsed)) return;
    setState(() {
      _ivaOptions.add(parsed);
      _ivaOptions.sort();
    });
  }

  Future<void> _adicionarTextoUnidade() async {
    _itemController.clear();
    final valor = await _mostrarDialogoInput(
      titulo: _t(context, pt: 'Adicionar unidade', en: 'Add unit'),
      label: _t(context, pt: 'Unidade (ex.: un, kg, h)', en: 'Unit (e.g., pc, kg, h)'),
    );
    if (valor == null) return;
    final texto = valor.trim();
    if (texto.isEmpty || _unidades.contains(texto)) return;
    setState(() => _unidades.add(texto));
  }

  Future<void> _adicionarTextoEstado() async {
    _itemController.clear();
    final valor = await _mostrarDialogoInput(
      titulo: _t(context, pt: 'Adicionar estado de fatura', en: 'Add invoice status'),
      label: _t(context, pt: 'Estado (ex.: emitida)', en: 'Status (e.g., issued)'),
    );
    if (valor == null) return;
    final texto = valor.trim().toLowerCase();
    if (texto.isEmpty || _estadosFatura.contains(texto)) return;
    setState(() => _estadosFatura.add(texto));
  }

  Future<void> _adicionarMeioPagamento() async {
    _itemController.clear();
    final valor = await _mostrarDialogoInput(
      titulo: _t(context, pt: 'Adicionar meio de pagamento', en: 'Add payment method'),
      label: _t(context, pt: 'Meio de pagamento (ex.: MB Way)', en: 'Payment method (e.g., MB Way)'),
    );
    if (valor == null) return;
    final texto = valor.trim();
    if (texto.isEmpty || _meiosPagamento.contains(texto)) return;
    setState(() => _meiosPagamento.add(texto));
  }

  Future<void> _adicionarTipoDocumento() async {
    _itemController.clear();
    final valor = await _mostrarDialogoInput(
      titulo: _t(context, pt: 'Adicionar tipo de documento', en: 'Add document type'),
      label: _t(context, pt: 'Tipo (ex.: Fatura Proforma)', en: 'Type (e.g., Proforma Invoice)'),
    );
    if (valor == null) return;
    final texto = valor.trim();
    if (texto.isEmpty || _tiposDocumento.contains(texto)) return;
    setState(() => _tiposDocumento.add(texto));
  }

  Future<String?> _mostrarDialogoInput({
    required String titulo,
    required String label,
    TextInputType keyboardType = TextInputType.text,
  }) async {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: TextField(
          controller: _itemController,
          keyboardType: keyboardType,
          decoration: InputDecoration(labelText: label),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(_t(context, pt: 'Cancelar', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(_itemController.text),
            child: Text(_t(context, pt: 'Adicionar', en: 'Add')),
          ),
        ],
      ),
    );
  }

  Future<void> _salvar(ConfiguracaoEmpresa cfg) async {
    final nome = _nomeEmpresaController.text.trim();
    final nif = _nifController.text.trim();
    final morada = _moradaController.text.trim();
    final codigoPostal = _codigoPostalController.text.trim();
    final localidade = _localidadeController.text.trim();
    final pais = _paisController.text.trim();
    final serie = _serieAtualController.text.trim();

    // Validações
    if (nome.isEmpty) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: _t(context, pt: 'Indique o nome da empresa.', en: 'Please enter the company name.'),
        tipo: TipoSnackBar.aviso,
      );
      _tabController.animateTo(0); // Ir para aba de dados básicos
      return;
    }

    if (nif.isEmpty) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: _t(context, pt: 'NIF é obrigatório.', en: 'Tax ID is required.'),
        tipo: TipoSnackBar.aviso,
      );
      _tabController.animateTo(1); // Ir para aba de dados fiscais
      return;
    }

    if (!FaturaLegalService.validarNIF(nif)) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: _t(context, pt: 'NIF inválido. Deve ter 9 dígitos válidos.', en: 'Invalid tax ID. It must contain 9 valid digits.'),
        tipo: TipoSnackBar.erro,
      );
      _tabController.animateTo(1);
      return;
    }

    if (morada.isEmpty || codigoPostal.isEmpty || localidade.isEmpty || pais.isEmpty) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: _t(context, pt: 'Morada, código postal, localidade e país são obrigatórios.', en: 'Address, postal code, city, and country are required.'),
        tipo: TipoSnackBar.aviso,
      );
      _tabController.animateTo(1);
      return;
    }

    if (!FaturaLegalService.validarCodigoPostal(codigoPostal)) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: _t(context, pt: 'Código postal inválido. Use o formato XXXX-XXX.', en: 'Invalid postal code. Use format XXXX-XXX.'),
        tipo: TipoSnackBar.erro,
      );
      _tabController.animateTo(1);
      return;
    }

    final email = _emailController.text.trim();
    final emailValidacao = FaturaLegalService.validarEmailComMensagem(email);
    if (!emailValidacao.valido) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: _t(context, pt: emailValidacao.erro!, en: 'Invalid email. Use format name@domain.com'),
        tipo: TipoSnackBar.erro,
      );
      _tabController.animateTo(1);
      return;
    }

    final telefone = _telefoneController.text.trim();
    final telefoneValidacao = FaturaLegalService.validarTelefoneComMensagem(telefone);
    if (!telefoneValidacao.valido) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: _t(context, pt: telefoneValidacao.erro!, en: 'Invalid phone. Use Portuguese format (e.g. 912345678 or +351912345678).'),
        tipo: TipoSnackBar.erro,
      );
      _tabController.animateTo(1);
      return;
    }

    final cae = _caeController.text.trim();
    final caeValidacao = FaturaLegalService.validarCAEComMensagem(cae);
    if (!caeValidacao.valido) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: _t(context, pt: caeValidacao.erro!, en: 'Invalid CAE. Must be 5 digits (e.g. 62020).'),
        tipo: TipoSnackBar.erro,
      );
      _tabController.animateTo(1);
      return;
    }

    if (serie.isEmpty) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: _t(context, pt: 'Série atual é obrigatória.', en: 'Current series is required.'),
        tipo: TipoSnackBar.aviso,
      );
      _tabController.animateTo(3); // Ir para aba de documentos
      return;
    }

    final config = ConfiguracaoEmpresa(
      nomeEmpresa: nome,
      nif: nif,
      morada: morada,
      codigoPostal: codigoPostal,
      localidade: localidade,
      pais: pais,
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      telefone: _telefoneController.text.trim().isEmpty ? null : _telefoneController.text.trim(),
      cae: _caeController.text.trim().isEmpty ? null : _caeController.text.trim(),
      capitalSocial: _capitalSocialController.text.trim().isEmpty ? null : _capitalSocialController.text.trim(),
      conservatoria: _conservatoriaController.text.trim().isEmpty ? null : _conservatoriaController.text.trim(),
      numeroRegistoComercial: _numeroRegistoComercialController.text.trim().isEmpty ? null : _numeroRegistoComercialController.text.trim(),
      numeroChaveCertificacaoAT: _numeroChaveCertificacaoATController.text.trim().isEmpty ? null : _numeroChaveCertificacaoATController.text.trim(),
      codigoValidacaoSoftwareAT: _codigoValidacaoSoftwareATController.text.trim().isEmpty ? null : _codigoValidacaoSoftwareATController.text.trim(),
      ivaOptions: _ivaOptions,
      unidades: _unidades,
      estadosFatura: _estadosFatura,
      meiosPagamento: _meiosPagamento,
      tiposDocumento: _tiposDocumento,
      serieAtual: serie,
      adminPinHash: _adminPinHash,
    );

    try {
      await ref.read(configuracoesProvider.notifier).salvarConfiguracoes(config);
      if (!mounted) return;
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: _t(context, pt: 'Configurações guardadas com sucesso.', en: 'Settings saved successfully.'),
        tipo: TipoSnackBar.sucesso,
      );
    } catch (e) {
      if (!mounted) return;
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: '${_t(context, pt: 'Erro ao guardar configurações', en: 'Error saving settings')}: $e',
        tipo: TipoSnackBar.erro,
      );
    }
  }

  Future<void> _mudarDiretorioBackup(ConfiguracaoEmpresa cfg) async {
    try {
      final novoDir = await BackupService.selecionarDiretorioBackup();
      if (novoDir == null || novoDir.isEmpty) {
        if (mounted) {
          UiHelpers.mostrarSnackBar(
            context,
            mensagem: _t(context, pt: 'Nenhum diretório selecionado.', en: 'No directory selected.'),
            tipo: TipoSnackBar.aviso,
          );
        }
        return;
      }

      final configAtualizada = cfg.copyWith(diretorioBackup: novoDir);
      await ref.read(configuracoesProvider.notifier).salvarConfiguracoes(configAtualizada);
      
      if (mounted) {
        setState(() {}); // Atualizar UI para mostrar novo diretório
        UiHelpers.mostrarSnackBar(
          context,
          mensagem: _t(context, pt: 'Diretório de backup alterado com sucesso.', en: 'Backup directory changed successfully.'),
          tipo: TipoSnackBar.sucesso,
        );
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.mostrarSnackBar(
          context,
          mensagem: '${_t(context, pt: 'Erro ao mudar diretório', en: 'Error changing directory')}: $e',
          tipo: TipoSnackBar.erro,
        );
      }
    }
  }

  Future<void> _alterarPin() async {
    final atualController = TextEditingController();
    final novoController = TextEditingController();
    final confirmarController = TextEditingController();

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t(context, pt: 'Alterar PIN de administrador', en: 'Change administrator PIN')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: atualController,
              decoration: InputDecoration(labelText: _t(context, pt: 'PIN atual', en: 'Current PIN')),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: novoController,
              decoration: InputDecoration(labelText: _t(context, pt: 'Novo PIN', en: 'New PIN')),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmarController,
              decoration: InputDecoration(labelText: _t(context, pt: 'Confirmar novo PIN', en: 'Confirm new PIN')),
              keyboardType: TextInputType.number,
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(_t(context, pt: 'Cancelar', en: 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(_t(context, pt: 'Guardar', en: 'Save')),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    if (!mounted) return;

    final atual = atualController.text.trim();
    final novo = novoController.text.trim();
    final confirmarNovo = confirmarController.text.trim();

    if (!await AdminAuthService.validarPin(atual)) {
      if (!mounted) return;
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: _t(context, pt: 'PIN atual inválido.', en: 'Current PIN is invalid.'),
        tipo: TipoSnackBar.erro,
      );
      return;
    }

    if (!mounted) return;

    if (novo.length < 4 || novo.length > 12) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: _t(context, pt: 'O novo PIN deve ter entre 4 e 12 dígitos.', en: 'The new PIN must be between 4 and 12 digits.'),
        tipo: TipoSnackBar.aviso,
      );
      return;
    }

    if (novo != confirmarNovo) {
      UiHelpers.mostrarSnackBar(
        context,
        mensagem: _t(context, pt: 'A confirmação do PIN não coincide.', en: 'PIN confirmation does not match.'),
        tipo: TipoSnackBar.aviso,
      );
      return;
    }

    setState(() {
      _adminPinHash = AdminAuthService.hashPin(novo);
    });

    if (!mounted) return;
    UiHelpers.mostrarSnackBar(
      context,
      mensagem: _t(context, pt: 'PIN de administrador atualizado. Não se esqueça de guardar alterações.', en: 'Administrator PIN updated. Do not forget to save your changes.'),
      tipo: TipoSnackBar.sucesso,
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/i18n/app_text.dart';

/// Modelo de dados para cada slide do tutorial.
class TutorialSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String>? features;

  const TutorialSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.features,
  });
}

/// Lista de slides do tutorial.
class TutorialSlides {
  static List<TutorialSlide> slides(BuildContext context) {
    String t({required String pt, required String en}) =>
        AppText.tr(context, pt: pt, en: en);

    return [
    TutorialSlide(
      title: t(pt: 'Bem-vindo ao Facturio', en: 'Welcome to Facturio'),
      description: t(
        pt: 'Sistema completo de faturação empresarial com gestão de clientes, produtos e pagamentos.',
        en: 'Complete business billing system with customer, product, and payment management.',
      ),
      icon: Icons.receipt_long,
      color: Colors.blue,
      features: [
        t(pt: 'Gestão offline com sincronização automática', en: 'Offline management with automatic sync'),
        t(pt: 'Interface moderna e intuitiva', en: 'Modern and intuitive interface'),
        t(pt: 'Relatórios financeiros em tempo real', en: 'Real-time financial reports'),
      ],
    ),
    TutorialSlide(
      title: t(pt: 'Gestão de Clientes', en: 'Customer Management'),
      description: t(pt: 'Cadastre e gerencie os seus clientes com informações completas.', en: 'Register and manage customers with complete information.'),
      icon: Icons.people,
      color: Colors.green,
      features: [
        t(pt: 'Cadastro completo com NIF e morada', en: 'Full profile with tax ID and address'),
        t(pt: 'Histórico de faturas por cliente', en: 'Invoice history per customer'),
        t(pt: 'Pesquisa rápida e eficiente', en: 'Fast and efficient search'),
      ],
    ),
    TutorialSlide(
      title: t(pt: 'Catálogo de Produtos', en: 'Product Catalog'),
      description: t(pt: 'Organize o seu inventário com controlo de stock e preços.', en: 'Organize inventory with stock and price control.'),
      icon: Icons.inventory,
      color: Colors.orange,
      features: [
        t(pt: 'Gestão de stock com alertas', en: 'Stock management with alerts'),
        t(pt: 'Múltiplas taxas de IVA', en: 'Multiple VAT rates'),
        t(pt: 'Preços personalizáveis', en: 'Customizable pricing'),
      ],
    ),
    TutorialSlide(
      title: t(pt: 'Faturação Profissional', en: 'Professional Invoicing'),
      description: t(pt: 'Emita faturas legais com QR Code e conformidade com a lei portuguesa.', en: 'Issue legal invoices with QR code and Portuguese compliance.'),
      icon: Icons.description,
      color: Colors.purple,
      features: [
        t(pt: 'Faturas com conformidade legal', en: 'Legally compliant invoices'),
        t(pt: 'QR Code automático (AT)', en: 'Automatic tax authority QR code'),
        t(pt: 'Cálculo de IVA e retenção na fonte', en: 'VAT and withholding tax calculation'),
      ],
    ),
    TutorialSlide(
      title: t(pt: 'Sistema de Pagamentos', en: 'Payment System'),
      description: t(pt: 'Controle pagamentos parciais e múltiplos meios de pagamento.', en: 'Track partial payments and multiple payment methods.'),
      icon: Icons.payments,
      color: Colors.teal,
      features: [
        t(pt: 'Múltiplos pagamentos parciais', en: 'Multiple partial payments'),
        t(pt: '10 meios de pagamento', en: '10 payment methods'),
        t(pt: 'Status visual com progresso', en: 'Visual status with progress'),
      ],
    ),
    TutorialSlide(
      title: t(pt: 'Impressão e Partilha', en: 'Printing and Sharing'),
      description: t(pt: 'Gere PDFs profissionais e exporte para Excel.', en: 'Generate professional PDFs and export to Excel.'),
      icon: Icons.print,
      color: Colors.indigo,
      features: [
        t(pt: 'PDF de alta qualidade', en: 'High-quality PDF output'),
        t(pt: 'Partilha direta por email/WhatsApp', en: 'Direct sharing by email/WhatsApp'),
        t(pt: 'Exportação para Excel (CSV)', en: 'Excel export (CSV)'),
      ],
    ),
    TutorialSlide(
      title: t(pt: 'Dashboard Inteligente', en: 'Smart Dashboard'),
      description: t(pt: 'Acompanhe o seu negócio com indicadores e resumos financeiros.', en: 'Track your business with KPIs and financial summaries.'),
      icon: Icons.dashboard,
      color: Colors.pink,
      features: [
        t(pt: 'Total faturado e recebido', en: 'Total invoiced and received'),
        t(pt: 'Faturas pendentes', en: 'Pending invoices'),
        t(pt: 'Alertas de stock baixo', en: 'Low stock alerts'),
      ],
    ),
    TutorialSlide(
      title: t(pt: 'Configurações Personalizadas', en: 'Custom Settings'),
      description: t(pt: 'Adapte o sistema às necessidades da sua empresa.', en: 'Adapt the system to your company needs.'),
      icon: Icons.settings,
      color: Colors.amber,
      features: [
        t(pt: 'Dados da empresa editáveis', en: 'Editable company data'),
        t(pt: 'Taxas de IVA personalizadas', en: 'Custom VAT rates'),
        t(pt: 'Meios de pagamento configuráveis', en: 'Configurable payment methods'),
        t(pt: 'Backup e restauro de dados', en: 'Data backup and restore'),
      ],
    ),
    ];
  }
}

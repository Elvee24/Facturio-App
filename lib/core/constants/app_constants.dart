class AppConstants {
  // App Info
  static const String appName = 'Facturio';
  static const String appVersion = '1.0.0';

  // Taxas de IVA em Portugal
  static const double ivaNormal = 23.0;
  static const double ivaIntermedio = 13.0;
  static const double ivaReduzido = 6.0;
  static const double ivaIsento = 0.0;

  static const List<double> ivaOptions = [
    ivaNormal,
    ivaIntermedio,
    ivaReduzido,
    ivaIsento,
  ];

  // Unidades
  static const List<String> unidades = [
    'un',
    'kg',
    'm',
    'm²',
    'm³',
    'l',
    'h',
  ];

  // Estados da Fatura
  static const String estadoRascunho = 'rascunho';
  static const String estadoEmitida = 'emitida';
  static const String estadoPaga = 'paga';
  static const String estadoCancelada = 'cancelada';

  static const List<String> estadosFatura = [
    estadoRascunho,
    estadoEmitida,
    estadoPaga,
    estadoCancelada,
  ];

  // Hive Box Names
  static const String clientesBox = 'clientes';
  static const String produtosBox = 'produtos';
  static const String faturasBox = 'faturas';
  static const String configBox = 'config';
}

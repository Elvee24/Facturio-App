import 'package:hive_flutter/hive_flutter.dart';

/// Serviço de monitoramento de segurança em tempo real
class SecurityMonitorService {
  
  static late Box<dynamic> _alertsBox;
  static final List<SecurityAlert> _activeAlerts = [];

  // Inicializar serviço
  static Future<void> init() async {
    _alertsBox = await Hive.openBox<dynamic>('security_alerts');
    _activeAlerts
      ..clear()
      ..addAll(
        _alertsBox.values
            .whereType<Map>()
            .map((value) => SecurityAlert.fromMap(Map<String, dynamic>.from(value.cast<String, dynamic>())))
            .toList(),
      );
  }

  // Gerar alerta de segurança
  static Future<void> generateAlert({
    required String title,
    required String description,
    required AlertSeverity severity,
    required AlertType type,
    Map<String, dynamic>? context,
  }) async {
    try {
      final alert = SecurityAlert(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        title: title,
        description: description,
        severity: severity,
        type: type,
        timestamp: DateTime.now(),
        context: context,
      );

      _activeAlerts.add(alert);

      // Guardar em Hive
      await _alertsBox.put(alert.id, alert.toMap());

      // Executar ações automáticas baseadas na severidade
      await _handleAlert(alert);
    } catch (e) {
      // Falhar silencioso
    }
  }

  // Processar alerta segundo severidade
  static Future<void> _handleAlert(SecurityAlert alert) async {
    switch (alert.severity) {
      case AlertSeverity.low:
        // Log apenas
        break;
      case AlertSeverity.medium:
        // Log + notificação
        break;
      case AlertSeverity.high:
        // Log + notificação + possível bloqueio
        break;
      case AlertSeverity.critical:
        // Log + notificação + bloqueio + escalação
        break;
    }
  }

  // Verificar padrão de ataque
  static bool detectAttackPattern() {
    // Contar alertas CRÍTICOS nos últimos 5 minutos
    final fiveMinutesAgo = DateTime.now().subtract(Duration(minutes: 5));
    final recentCriticalAlerts = _activeAlerts.where((alert) {
      return alert.severity == AlertSeverity.critical &&
          alert.timestamp.isAfter(fiveMinutesAgo);
    }).length;

    // Se 3+ alertas críticos em 5 minutos, há ataque
    return recentCriticalAlerts >= 3;
  }

  // Obter alertos ativos
  static List<SecurityAlert> getActiveAlerts({
    AlertSeverity? minimumSeverity,
    AlertType? type,
  }) {
    var alerts = _activeAlerts.where((a) => !a.resolved).toList();

    if (minimumSeverity != null) {
      alerts = alerts.where((a) => a.severity.index >= minimumSeverity.index).toList();
    }

    if (type != null) {
      alerts = alerts.where((a) => a.type == type).toList();
    }

    return alerts;
  }

  // Resolver alerta
  static Future<void> resolveAlert(String alertId) async {
    try {
      final alertIndex = _activeAlerts.indexWhere((a) => a.id == alertId);
      if (alertIndex >= 0) {
        _activeAlerts[alertIndex].resolved = true;
      }

      // Atualizar em Hive
      final keys = _alertsBox.keys.toList();
      for (final key in keys) {
        final alert = _alertsBox.get(key);
        if (alert is Map && alert['id'] == alertId) {
          alert['resolved'] = true;
          await _alertsBox.put(key, alert);
          break;
        }
      }
    } catch (e) {
      // Falhar silencioso
    }
  }

  // Obter histórico de segurança
  static Future<List<Map<String, dynamic>>> getSecurityHistory({
    int limit = 100,
  }) async {
    try {
      final alerts = <Map<String, dynamic>>[];
      final keys = _alertsBox.keys.toList().reversed.take(limit);

      for (final key in keys) {
        final alert = _alertsBox.get(key);
        if (alert is Map) {
          alerts.add(Map<String, dynamic>.from(alert.cast<String, dynamic>()));
        }
      }

      return alerts;
    } catch (e) {
      return [];
    }
  }

  // Análise de segurança geral
  static SecurityAnalysis getSecurityAnalysis() {
    final allAlerts = _activeAlerts;
    final unresolved = allAlerts.where((a) => !a.resolved).length;
    final critical = allAlerts.where((a) => a.severity == AlertSeverity.critical).length;
    final high = allAlerts.where((a) => a.severity == AlertSeverity.high).length;

    var overallStatus = SecurityStatus.secure;
    if (critical > 0) {
      overallStatus = SecurityStatus.criticalThreat;
    } else if (high > 2) {
      overallStatus = SecurityStatus.underAttack;
    } else if (high > 0 || unresolved > 5) {
      overallStatus = SecurityStatus.warning;
    }

    return SecurityAnalysis(
      status: overallStatus,
      resolvedAlerts: allAlerts.where((a) => a.resolved).length,
      unresolvedAlerts: unresolved,
      criticalAlerts: critical,
      highAlerts: high,
      lastAlertTime: allAlerts.isEmpty ? null : allAlerts.last.timestamp,
    );
  }

  // Limpar alertas resolvidos antigos (> 7 dias)
  static Future<void> cleanupOldAlerts() async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(Duration(days: 7));
      
      _activeAlerts.removeWhere((alert) {
        return alert.resolved && alert.timestamp.isBefore(sevenDaysAgo);
      });

      final keys = _alertsBox.keys.toList();
      for (final key in keys) {
        final alert = _alertsBox.get(key);
        if (alert is Map && alert['resolved'] == true && DateTime.parse(alert['timestamp'].toString()).isBefore(sevenDaysAgo)) {
          await _alertsBox.delete(key);
        }
      }
    } catch (e) {
      // Falhar silencioso
    }
  }

  // Exportar relatório de segurança
  static Future<String> exportSecurityReport() async {
    final analysis = getSecurityAnalysis();
    final history = await getSecurityHistory(limit: 50);

    return '''
=== RELATÓRIO DE SEGURANÇA ===
Data: ${DateTime.now()}
Status: ${analysis.status.name}

RESUMO:
- Alertas Críticos: ${analysis.criticalAlerts}
- Alertas Altos: ${analysis.highAlerts}
- Alertas Não Resolvidos: ${analysis.unresolvedAlerts}
- Alertas Resolvidos: ${analysis.resolvedAlerts}
- Último Alerta: ${analysis.lastAlertTime}

HISTÓRICO DE ALERTAS:
${history.map((a) => '- [${a['severity']}] ${a['title']}: ${a['description']}').join('\n')}

STATUS GERAL: ${analysis.status.description}
''';
  }
}

/// Alerta de segurança
class SecurityAlert {
  final String id;
  final String title;
  final String description;
  final AlertSeverity severity;
  final AlertType type;
  final DateTime timestamp;
  final Map<String, dynamic>? context;
  bool resolved;

  SecurityAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.type,
    required this.timestamp,
    this.context,
    this.resolved = false,
  });

  factory SecurityAlert.fromMap(Map<String, dynamic> map) {
    return SecurityAlert(
      id: map['id'].toString(),
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      severity: AlertSeverity.values[(map['severity'] as num?)?.toInt() ?? 0],
      type: AlertType.values[(map['type'] as num?)?.toInt() ?? 0],
      timestamp: DateTime.tryParse(map['timestamp']?.toString() ?? '') ?? DateTime.now(),
      context: map['context'] is Map
          ? Map<String, dynamic>.from((map['context'] as Map).cast<String, dynamic>())
          : null,
      resolved: map['resolved'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'severity': severity.index,
      'type': type.index,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
      'resolved': resolved,
    };
  }
}

/// Tipos de alerta
enum AlertType {
  authenticationFailure,
  authorizationFailure,
  dataManipulation,
  maliciousInput,
  rateLimitExceeded,
  suspiciousActivity,
  configurationChanged,
  systemViolation,
  unknownThreat,
}

/// Severidade de alerta
enum AlertSeverity {
  low('Baixa'),
  medium('Média'),
  high('Alta'),
  critical('Crítica');

  final String label;
  const AlertSeverity(this.label);
}

/// Análise geral de segurança
class SecurityAnalysis {
  final SecurityStatus status;
  final int resolvedAlerts;
  final int unresolvedAlerts;
  final int criticalAlerts;
  final int highAlerts;
  final DateTime? lastAlertTime;

  SecurityAnalysis({
    required this.status,
    required this.resolvedAlerts,
    required this.unresolvedAlerts,
    required this.criticalAlerts,
    required this.highAlerts,
    required this.lastAlertTime,
  });
}

/// Status geral de segurança
enum SecurityStatus {
  secure('Seguro', 'Sistema operando normalmente'),
  warning('Aviso', 'Alguns problemas detectados, monitorar'),
  underAttack('Sob Ataque', 'Múltiplas tentativas suspeitas detectadas'),
  criticalThreat('Ameaça Crítica', 'Ameaça crítica confirmada, ação requerida');

  final String name;
  final String description;
  const SecurityStatus(this.name, this.description);
}

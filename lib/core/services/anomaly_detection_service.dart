import 'dart:collection';
import 'package:hive_flutter/hive_flutter.dart';

/// Serviço de detecção de anomalias comportamentais
class AnomalyDetectionService {
  
  static late Box<dynamic> _anomalyBox;

  // Histórico de comportamento do utilizador
  static final Map<String, UserBehaviorProfile> _behaviorProfiles = {};

  // Inicializar serviço
  static Future<void> init() async {
    _anomalyBox = await Hive.openBox<dynamic>('anomaly_detection');

    for (final entry in _anomalyBox.toMap().entries) {
      final value = entry.value;
      if (value is Map) {
        final map = Map<String, dynamic>.from(value.cast<String, dynamic>());
        final userId = map['userId'];
        if (userId is String && userId.isNotEmpty) {
          _behaviorProfiles[userId] = UserBehaviorProfile.fromJson(map);
        }
      }
    }
  }

  // Registar atividade do utilizador
  static Future<void> recordActivity(
    String userId,
    String action,
    Map<String, dynamic> metadata,
  ) async {
    try {
      final profile = _behaviorProfiles[userId] ??
          UserBehaviorProfile(userId: userId);

      final activity = UserActivity(
        timestamp: DateTime.now(),
        action: action,
        metadata: metadata,
      );

      profile.addActivity(activity);
      _behaviorProfiles[userId] = profile;

      // Guardar em Hive
      await _anomalyBox.put(userId, profile.toJson());
    } catch (e) {
      // Falhar silencioso
    }
  }

  // Detectar anomalias no comportamento
  static AnomalyDetectionResult detectAnomalies(String userId) {
    final profile = _behaviorProfiles[userId];
    if (profile == null) {
      return AnomalyDetectionResult(
        hasAnomalies: false,
        anomalies: [],
        riskLevel: RiskLevel.low,
      );
    }

    final anomalies = <String>[];
    var riskLevel = RiskLevel.low;

    // Verificar padrão 1: Muitas ações rápidas (possível automatização)
    if (profile.detectRapidActions()) {
      anomalies.add('Muitas ações executadas rapidamente (possível automatização)');
      riskLevel = RiskLevel.medium;
    }

    // Verificar padrão 2: Acesso de localizações geograficamente impossíveis
    if (profile.detectImpossibleLocations()) {
      anomalies.add('Acesso de múltiplas localizações geograficamente impossíveis');
      riskLevel = RiskLevel.high;
    }

    // Verificar padrão 3: Ações incomuns
    if (profile.detectUnusualActions()) {
      anomalies.add('Ações não comummente realizadas por este utilizador');
      riskLevel = RiskLevel.medium;
    }

    // Verificar padrão 4: Acesso fora de horários normais
    if (profile.detectUnusualTiming()) {
      anomalies.add('Acesso fora dos horários habituais');
      riskLevel = RiskLevel.low;
    }

    // Verificar padrão 5: Operações em massa suspeitas
    if (profile.detectMassOperations()) {
      anomalies.add('Múltiplas operações deletoras/exportadoras em sequência');
      riskLevel = RiskLevel.high;
    }

    return AnomalyDetectionResult(
      hasAnomalies: anomalies.isNotEmpty,
      anomalies: anomalies,
      riskLevel: riskLevel,
    );
  }

  // Validar se ação é suspeita
  static bool isSuspiciousAction(
    String userId,
    String action,
  ) {
    final profile = _behaviorProfiles[userId];
    if (profile == null) return false;

    final suspiciousActions = [
      'export_all',
      'delete_all',
      'bulk_delete',
      'bulk_export',
      'access_admin',
      'change_password',
      'disable_security',
    ];

    return suspiciousActions.contains(action);
  }

  // Obter perfil de comportamento
  static UserBehaviorProfile? getUserProfile(String userId) {
    return _behaviorProfiles[userId];
  }

  // Resetar perfil (após mudança de password, etc)
  static Future<void> resetProfile(String userId) async {
    _behaviorProfiles.remove(userId);
    await _anomalyBox.delete(userId);
  }

  // Limpar dados antigos (> 30 dias)
  static Future<void> cleanupOldData() async {
    final thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
    
    for (final profile in _behaviorProfiles.values) {
      profile.activities.removeWhere((activity) {
        return activity.timestamp.isBefore(thirtyDaysAgo);
      });
    }
  }
}

/// Perfil comportamental do utilizador
class UserBehaviorProfile {
  final String userId;
  final ListQueue<UserActivity> activities = ListQueue(1000);

  UserBehaviorProfile({required this.userId});

  factory UserBehaviorProfile.fromJson(Map<String, dynamic> json) {
    final profile = UserBehaviorProfile(userId: json['userId'] as String);
    final storedActivities = json['activities'];
    if (storedActivities is List) {
      for (final item in storedActivities) {
        if (item is Map) {
          final map = Map<String, dynamic>.from(item.cast<String, dynamic>());
          final timestamp = DateTime.tryParse(map['timestamp']?.toString() ?? '');
          final action = map['action']?.toString();
          final metadata = map['metadata'];
          if (timestamp != null && action != null) {
            profile.addActivity(
              UserActivity(
                timestamp: timestamp,
                action: action,
                metadata: metadata is Map
                    ? Map<String, dynamic>.from(metadata.cast<String, dynamic>())
                    : <String, dynamic>{},
              ),
            );
          }
        }
      }
    }
    return profile;
  }

  void addActivity(UserActivity activity) {
    activities.add(activity);
    if (activities.length > 1000) {
      activities.removeFirst();
    }
  }

  // Detectar ações rápidas demais
  bool detectRapidActions() {
    if (activities.length < 5) return false;

    final allActivities = activities.toList();
    final recentActivities = allActivities.sublist(allActivities.length - 5);
    if (recentActivities.length < 5) return false;

    final timespan = recentActivities.last.timestamp.difference(recentActivities.first.timestamp);
    // 5 ações em menos de 5 segundos é suspeito
    return timespan.inSeconds < 5;
  }

  // Detectar localizações geograficamente impossíveis
  bool detectImpossibleLocations() {
    // Versão simplificada - teria geolocalização em produção
    return false;
  }

  // Detectar ações incomuns
  bool detectUnusualActions() {
    if (activities.isEmpty) return false;

    final commonActions = {
      'view_cliente': 0,
      'create_fatura': 0,
      'edit_produto': 0,
      'view_dashboard': 0,
    };

    for (final activity in activities) {
      if (commonActions.containsKey(activity.action)) {
        commonActions[activity.action] = commonActions[activity.action]! + 1;
      }
    }

    // Se existe ações rares muito frequentemente
    final uncommonCount = activities.where((a) {
      return !commonActions.containsKey(a.action);
    }).length;

    return (uncommonCount / activities.length) > 0.5;
  }

  // Detectar acesso fora de horários normais
  bool detectUnusualTiming() {
    if (activities.isEmpty) return false;

    // Horários normais: 09:00 - 18:00
    final recentActivities = activities.toList().sublist(
      activities.length > 10 ? activities.length - 10 : 0,
    );

    final abnormalCount = recentActivities.where((a) {
      final hour = a.timestamp.hour;
      return hour < 6 || hour > 23;
    }).length;

    return (abnormalCount / recentActivities.length) > 0.7;
  }

  // Detectar operações em massa
  bool detectMassOperations() {
    if (activities.length < 3) return false;

    final lastThree = activities.toList().sublist(activities.length - 3);
    final isDeletious = lastThree.every((a) =>
        a.action.contains('delete') ||
        a.action.contains('export') ||
        a.action.contains('remove'));

    return isDeletious;
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'activities': activities
          .map((a) => {
                'timestamp': a.timestamp.toIso8601String(),
                'action': a.action,
                'metadata': a.metadata,
              })
          .toList(),
    };
  }
}

/// Atividade individual do utilizador
class UserActivity {
  final DateTime timestamp;
  final String action;
  final Map<String, dynamic> metadata;

  UserActivity({
    required this.timestamp,
    required this.action,
    required this.metadata,
  });
}

/// Resultado da detecção de anomalias
class AnomalyDetectionResult {
  final bool hasAnomalies;
  final List<String> anomalies;
  final RiskLevel riskLevel;

  AnomalyDetectionResult({
    required this.hasAnomalies,
    required this.anomalies,
    required this.riskLevel,
  });

  @override
  String toString() {
    if (!hasAnomalies) {
      return 'Nenhuma anomalia detectada';
    }
    return 'Anomalias (${riskLevel.name}): ${anomalies.join(", ")}';
  }
}

/// Níveis de risco
enum RiskLevel {
  low('Baixo'),
  medium('Médio'),
  high('Alto'),
  critical('Crítico');

  final String label;
  const RiskLevel(this.label);
}

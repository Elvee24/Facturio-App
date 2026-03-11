import 'dart:async';

/// Serviço de rate limiting para proteção contra brute force e DDoS
class RateLimiterService {
  
  static final Map<String, List<DateTime>> _requestLog = {};
  static final Map<String, Timer> _cleanupTimers = {};

  // Limites por operação
  static const Map<String, RateLimit> operationLimits = {
    'login': RateLimit(maxRequests: 5, windowSeconds: 60),
    'export': RateLimit(maxRequests: 10, windowSeconds: 3600),
    'import': RateLimit(maxRequests: 10, windowSeconds: 3600),
    'delete': RateLimit(maxRequests: 20, windowSeconds: 3600),
    'api_call': RateLimit(maxRequests: 100, windowSeconds: 60),
    'file_upload': RateLimit(maxRequests: 5, windowSeconds: 300),
    'data_sync': RateLimit(maxRequests: 30, windowSeconds: 3600),
  };

  // Verificar se operação é permitida
  static RateLimitResult checkRateLimit(
    String operationKey, {
    String? userId,
    bool strictMode = true,
  }) {
    final key = userId != null ? '$operationKey:$userId' : operationKey;
    final limit = operationLimits[operationKey] ?? RateLimit(maxRequests: 100, windowSeconds: 3600);

    final now = DateTime.now();
    final requestList = _requestLog[key] ?? [];

    // Remover requisições fora da janela de tempo
    final validRequests = requestList
        .where((t) => now.difference(t).inSeconds < limit.windowSeconds)
        .toList();

    if (validRequests.length >= limit.maxRequests) {
      // Limite excedido
      final oldestRequest = validRequests.first;
      final resetTime = oldestRequest.add(Duration(seconds: limit.windowSeconds));
      final remainingSeconds = resetTime.difference(now).inSeconds;

      return RateLimitResult(
        allowed: false,
        remainingRequests: 0,
        resetIn: Duration(seconds: remainingSeconds),
        message: 'Limite de taxa excedido. Tente novamente em $remainingSeconds segundos.',
      );
    }

    // Adicionar nova requisição
    validRequests.add(now);
    _requestLog[key] = validRequests;

    // Agendar limpeza automática
    _scheduleCleanup(key, limit.windowSeconds);

    return RateLimitResult(
      allowed: true,
      remainingRequests: limit.maxRequests - validRequests.length,
      resetIn: Duration(seconds: limit.windowSeconds),
      message: 'Permitido (${limit.maxRequests - validRequests.length}/${limit.maxRequests} restantes)',
    );
  }

  // Agendar limpeza de logs antigos
  static void _scheduleCleanup(String key, int windowSeconds) {
    if (_cleanupTimers.containsKey(key)) {
      return;
    }

    _cleanupTimers[key] = Timer(
      Duration(seconds: windowSeconds + 60),
      () {
        _requestLog.remove(key);
        _cleanupTimers.remove(key);
      },
    );
  }

  // Resetar limite para uma operação (uso administrativo)
  static void resetRateLimit(String operationKey, {String? userId}) {
    final key = userId != null ? '$operationKey:$userId' : operationKey;
    _requestLog.remove(key);
    _cleanupTimers[key]?.cancel();
    _cleanupTimers.remove(key);
  }

  // Obter status de rate limit
  static RateLimitStatus getStatus(
    String operationKey, {
    String? userId,
  }) {
    final key = userId != null ? '$operationKey:$userId' : operationKey;
    final limit = operationLimits[operationKey] ?? RateLimit(maxRequests: 100, windowSeconds: 3600);
    
    final requestList = _requestLog[key] ?? [];
    final now = DateTime.now();
    
    final validRequests = requestList
        .where((t) => now.difference(t).inSeconds < limit.windowSeconds)
        .toList();

    return RateLimitStatus(
      operationKey: operationKey,
      userId: userId,
      currentRequests: validRequests.length,
      maxRequests: limit.maxRequests,
      windowSeconds: limit.windowSeconds,
      percentageUsed: (validRequests.length / limit.maxRequests * 100).toStringAsFixed(1),
    );
  }

  // Limpar todos os logs (uso administrativo)
  static void clearAllLogs() {
    _requestLog.clear();
    for (final timer in _cleanupTimers.values) {
      timer.cancel();
    }
    _cleanupTimers.clear();
  }

  // Detectar padrão de ataque (muitas tentativas rápidas)
  static bool detectBruteForcePattern(
    String operationKey, {
    String? userId,
    int failuresThreshold = 5,
  }) {
    final key = userId != null ? '$operationKey:$userId' : operationKey;
    final requestList = _requestLog[key] ?? [];
    final now = DateTime.now();

    // Contar requisições nos últimos 60 segundos
    final recentRequests = requestList
        .where((t) => now.difference(t).inSeconds < 60)
        .toList();

    return recentRequests.length >= failuresThreshold;
  }

  // Implementar backoff exponencial
  static Duration calculateBackoffDuration(
    int failureCount, {
    Duration baseDuration = const Duration(seconds: 1),
    int maxMultiplier = 32,
  }) {
    final multiplier = [1 << failureCount, maxMultiplier].reduce((a, b) => a < b ? a : b);
    return baseDuration * multiplier;
  }
}

/// Definição de limite de taxa
class RateLimit {
  final int maxRequests;
  final int windowSeconds;

  const RateLimit({
    required this.maxRequests,
    required this.windowSeconds,
  });
}

/// Resultado da verificação de rate limit
class RateLimitResult {
  final bool allowed;
  final int remainingRequests;
  final Duration resetIn;
  final String message;

  RateLimitResult({
    required this.allowed,
    required this.remainingRequests,
    required this.resetIn,
    required this.message,
  });

  @override
  String toString() => message;
}

/// Status de rate limit
class RateLimitStatus {
  final String operationKey;
  final String? userId;
  final int currentRequests;
  final int maxRequests;
  final int windowSeconds;
  final String percentageUsed;

  RateLimitStatus({
    required this.operationKey,
    required this.userId,
    required this.currentRequests,
    required this.maxRequests,
    required this.windowSeconds,
    required this.percentageUsed,
  });

  bool get isLimitReached => currentRequests >= maxRequests;
  bool get isWarning => (currentRequests / maxRequests) > 0.8;

  @override
  String toString() => '$operationKey: $currentRequests/$maxRequests ($percentageUsed%)';
}

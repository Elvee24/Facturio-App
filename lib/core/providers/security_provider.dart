import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/admin_auth_service.dart';
import '../services/secure_data_service.dart';
import '../services/file_security_service.dart';

/// Provider para gerenciar estado de segurança da app
class SecurityState {
  final bool isInitialized;
  final bool isAuthenticated;
  final int? failedAttempts;
  final Duration? lockoutRemaining;
  final String? errorMessage;

  SecurityState({
    required this.isInitialized,
    required this.isAuthenticated,
    this.failedAttempts,
    this.lockoutRemaining,
    this.errorMessage,
  });

  SecurityState copyWith({
    bool? isInitialized,
    bool? isAuthenticated,
    int? failedAttempts,
    Duration? lockoutRemaining,
    String? errorMessage,
  }) {
    return SecurityState(
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutRemaining: lockoutRemaining ?? this.lockoutRemaining,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Notifier para gerenciar operações de segurança
class SecurityNotifier extends StateNotifier<SecurityState> {
  SecurityNotifier()
      : super(SecurityState(
          isInitialized: false,
          isAuthenticated: false,
        ));

  // Inicializar serviços de segurança
  Future<void> initializeSecurity() async {
    try {
      // Inicializar autenticação
      await AdminAuthService.init();
      
      // Inicializar dados seguros
      await SecureDataService.init();
      
      // Inicializar segurança de ficheiros
      await FileSecurityService.getSecureAppDataDirectory();
      
      state = state.copyWith(
        isInitialized: true,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        isInitialized: false,
        errorMessage: 'Falha ao inicializar segurança: $e',
      );
    }
  }

  // Autenticar com PIN
  Future<bool> authenticateWithPin(String pin) async {
    try {
      // Verificar bloqueio
      if (await AdminAuthService.isLockedOut()) {
        final remaining = await AdminAuthService.getRemainingLockoutDuration();
        state = state.copyWith(
          isAuthenticated: false,
          lockoutRemaining: remaining,
          errorMessage: 'Conta bloqueada. Tente novamente em ${remaining?.inMinutes} minutos.',
        );
        return false;
      }

      // Validar PIN
      final isValid = await AdminAuthService.validarPin(pin);
      
      if (isValid) {
        // Definir chave mestre para encriptação
        await SecureDataService.setMasterKey(pin);
        
        state = state.copyWith(
          isAuthenticated: true,
          failedAttempts: 0,
          lockoutRemaining: null,
          errorMessage: null,
        );
        return true;
      } else {
        // Atualizar tentativas falhadas
        final failedAttempts = await AdminAuthService.getFailedAttemptsCount();
        final remaining = failedAttempts >= AdminAuthService.maxAttemptsPerHour
            ? await AdminAuthService.getRemainingLockoutDuration()
            : null;
        
        state = state.copyWith(
          isAuthenticated: false,
          failedAttempts: failedAttempts,
          lockoutRemaining: remaining,
          errorMessage: 'PIN inválido ($failedAttempts/${AdminAuthService.maxAttemptsPerHour})',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        errorMessage: 'Erro na autenticação: $e',
      );
      return false;
    }
  }

  // Mudar PIN
  Future<bool> changePin(String oldPin, String newPin) async {
    try {
      final success = await AdminAuthService.mudarPin(oldPin, newPin);
      
      if (success) {
        await SecureDataService.setMasterKey(newPin);
        state = state.copyWith(
          errorMessage: 'PIN alterado com sucesso',
        );
        return true;
      } else {
        state = state.copyWith(
          errorMessage: 'Falha ao alterar PIN',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao alterar PIN: $e',
      );
      return false;
    }
  }

  // Fazer logout
  Future<void> logout() async {
    try {
      SecureDataService.clearMasterKey();
      state = state.copyWith(
        isAuthenticated: false,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Erro ao fazer logout: $e',
      );
    }
  }

  // Obter histórico de auditoria
  Future<List<Map<String, dynamic>>> getAuditLog({int limit = 50}) async {
    try {
      return await AdminAuthService.getAuditLog(limit: limit);
    } catch (e) {
      return [];
    }
  }

  // Exportar log de auditoria encriptado
  Future<String?> exportAuditLogEncrypted(String password) async {
    try {
      return await AdminAuthService.exportAuditLogEncrypted(password);
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Falha ao exportar auditoria: $e',
      );
      return null;
    }
  }

  // Limpar erro
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Riverpod providers
final securityProvider = StateNotifierProvider<SecurityNotifier, SecurityState>(
  (ref) => SecurityNotifier(),
);

/// Provider para verificar se está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(securityProvider).isAuthenticated;
});

/// Provider para obter mensagem de erro
final securityErrorProvider = Provider<String?>((ref) {
  return ref.watch(securityProvider).errorMessage;
});

/// Provider para obter tentativas falhadas
final failedAttemptsProvider = Provider<int>((ref) {
  return ref.watch(securityProvider).failedAttempts ?? 0;
});

/// Provider para obter duração do bloqueio
final lockoutRemainingProvider = Provider<Duration?>((ref) {
  return ref.watch(securityProvider).lockoutRemaining;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/fatura_model.dart';
import '../../domain/entities/fatura.dart';
import '../../../clientes/presentation/providers/clientes_provider.dart';
import 'package:uuid/uuid.dart';

// Provider da lista de faturas
final faturasProvider =
    StateNotifierProvider<FaturasNotifier, AsyncValue<List<Fatura>>>((ref) {
  return FaturasNotifier(ref.watch(storageServiceProvider));
});

class FaturasNotifier extends StateNotifier<AsyncValue<List<Fatura>>> {
  final StorageService _storage;
  final _uuid = const Uuid();

  FaturasNotifier(this._storage) : super(const AsyncValue.loading()) {
    loadFaturas();
  }

  Future<void> loadFaturas() async {
    state = const AsyncValue.loading();
    try {
      final faturas = await _storage.getFaturas();
      // Ordenar por data decrescente
      faturas.sort((a, b) => b.data.compareTo(a.data));
      state = AsyncValue.data(faturas);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addFatura(Fatura fatura) async {
    try {
      final numeroFatura = await _storage.getProximoNumeroFatura();
      
      final faturaModel = FaturaModel(
        id: _uuid.v4(),
        numero: numeroFatura,
        data: DateTime.now(),
        clienteId: fatura.clienteId,
        clienteNome: fatura.clienteNome,
        linhas: fatura.linhas,
        estado: fatura.estado,
      );
      
      await _storage.saveFatura(faturaModel);
      await loadFaturas();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateFatura(Fatura fatura) async {
    try {
      final faturaModel = FaturaModel.fromEntity(fatura);
      await _storage.saveFatura(faturaModel);
      await loadFaturas();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFatura(String id) async {
    try {
      await _storage.deleteFatura(id);
      await loadFaturas();
    } catch (e) {
      rethrow;
    }
  }

  Future<Fatura?> getFatura(String id) async {
    return await _storage.getFatura(id);
  }

  Future<void> updateEstado(String id, String novoEstado) async {
    try {
      final fatura = await _storage.getFatura(id);
      if (fatura != null) {
        final faturaAtualizada = fatura.copyWith(estado: novoEstado);
        await _storage.saveFatura(FaturaModel.fromEntity(faturaAtualizada));
        await loadFaturas();
      }
    } catch (e) {
      rethrow;
    }
  }
}

// Provider para faturação por período
final faturacaoPorPeriodoProvider = Provider.family<double, DateTime>((ref, data) {
  final faturasAsync = ref.watch(faturasProvider);
  
  return faturasAsync.when(
    data: (faturas) {
      final faturasDoMes = faturas.where((f) {
        return f.data.month == data.month &&
            f.data.year == data.year &&
            f.estado != 'cancelada';
      });
      
      return faturasDoMes.fold(0.0, (sum, f) => sum + f.total);
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

// Provider para total de faturas por estado
final faturasporEstadoProvider = Provider.family<int, String>((ref, estado) {
  final faturasAsync = ref.watch(faturasProvider);
  
  return faturasAsync.when(
    data: (faturas) => faturas.where((f) => f.estado == estado).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

// Provider para total faturado
final totalFaturadoProvider = Provider<double>((ref) {
  final faturasAsync = ref.watch(faturasProvider);
  
  return faturasAsync.when(
    data: (faturas) {
      final faturasValidas = faturas.where((f) => f.estado != 'cancelada');
      return faturasValidas.fold(0.0, (sum, f) => sum + f.total);
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/cliente_model.dart';
import '../../domain/entities/cliente.dart';
import 'package:uuid/uuid.dart';

// Provider do serviço de storage
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

// Provider da lista de clientes
final clientesProvider =
    StateNotifierProvider<ClientesNotifier, AsyncValue<List<Cliente>>>((ref) {
  return ClientesNotifier(ref.watch(storageServiceProvider));
});

class ClientesNotifier extends StateNotifier<AsyncValue<List<Cliente>>> {
  final StorageService _storage;
  final _uuid = const Uuid();

  ClientesNotifier(this._storage) : super(const AsyncValue.loading()) {
    loadClientes();
  }

  Future<void> loadClientes() async {
    state = const AsyncValue.loading();
    try {
      final clientes = await _storage.getClientes();
      state = AsyncValue.data(clientes);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addCliente(Cliente cliente) async {
    try {
      final clienteModel = ClienteModel(
        id: _uuid.v4(),
        nome: cliente.nome,
        nif: cliente.nif,
        email: cliente.email,
        telefone: cliente.telefone,
        morada: cliente.morada,
        dataCriacao: DateTime.now(),
      );
      
      await _storage.saveCliente(clienteModel);
      await loadClientes();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCliente(Cliente cliente) async {
    try {
      final clienteModel = ClienteModel.fromEntity(cliente);
      await _storage.saveCliente(clienteModel);
      await loadClientes();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCliente(String id) async {
    try {
      await _storage.deleteCliente(id);
      await loadClientes();
    } catch (e) {
      rethrow;
    }
  }

  Future<Cliente?> getCliente(String id) async {
    return await _storage.getCliente(id);
  }
}

// Provider para pesquisar clientes
final clienteSearchProvider = Provider.family<List<Cliente>, String>((ref, query) {
  final clientesAsync = ref.watch(clientesProvider);
  
  return clientesAsync.when(
    data: (clientes) {
      if (query.isEmpty) return clientes;
      
      final queryLower = query.toLowerCase();
      return clientes.where((cliente) {
        return cliente.nome.toLowerCase().contains(queryLower) ||
            cliente.nif.contains(query) ||
            cliente.email.toLowerCase().contains(queryLower);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

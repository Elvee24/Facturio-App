import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/models/produto_model.dart';
import '../../domain/entities/produto.dart';
import '../../../clientes/presentation/providers/clientes_provider.dart';
import 'package:uuid/uuid.dart';

// Provider da lista de produtos
final produtosProvider =
    StateNotifierProvider<ProdutosNotifier, AsyncValue<List<Produto>>>((ref) {
  return ProdutosNotifier(ref.watch(storageServiceProvider));
});

class ProdutosNotifier extends StateNotifier<AsyncValue<List<Produto>>> {
  final StorageService _storage;
  final _uuid = const Uuid();

  ProdutosNotifier(this._storage) : super(const AsyncValue.loading()) {
    loadProdutos();
  }

  Future<void> loadProdutos() async {
    state = const AsyncValue.loading();
    try {
      final produtos = await _storage.getProdutos();
      state = AsyncValue.data(produtos);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addProduto(Produto produto) async {
    try {
      final produtoModel = ProdutoModel(
        id: _uuid.v4(),
        nome: produto.nome,
        descricao: produto.descricao,
        preco: produto.preco,
        iva: produto.iva,
        unidade: produto.unidade,
        stock: produto.stock,
      );
      
      await _storage.saveProduto(produtoModel);
      await loadProdutos();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduto(Produto produto) async {
    try {
      final produtoModel = ProdutoModel.fromEntity(produto);
      await _storage.saveProduto(produtoModel);
      await loadProdutos();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProduto(String id) async {
    try {
      await _storage.deleteProduto(id);
      await loadProdutos();
    } catch (e) {
      rethrow;
    }
  }

  Future<Produto?> getProduto(String id) async {
    return await _storage.getProduto(id);
  }

  Future<void> updateStock(String id, int quantidade) async {
    try {
      final produto = await _storage.getProduto(id);
      if (produto != null) {
        final produtoAtualizado = produto.copyWith(
          stock: produto.stock + quantidade,
        );
        await _storage.saveProduto(ProdutoModel.fromEntity(produtoAtualizado));
        await loadProdutos();
      }
    } catch (e) {
      rethrow;
    }
  }
}

// Provider para pesquisar produtos
final produtoSearchProvider = Provider.family<List<Produto>, String>((ref, query) {
  final produtosAsync = ref.watch(produtosProvider);
  
  return produtosAsync.when(
    data: (produtos) {
      if (query.isEmpty) return produtos;
      
      final queryLower = query.toLowerCase();
      return produtos.where((produto) {
        return produto.nome.toLowerCase().contains(queryLower) ||
            produto.descricao.toLowerCase().contains(queryLower);
      }).toList();
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Provider para produtos com stock baixo
final produtosStockBaixoProvider = Provider<List<Produto>>((ref) {
  final produtosAsync = ref.watch(produtosProvider);
  
  return produtosAsync.when(
    data: (produtos) => produtos.where((p) => p.stock < 10).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

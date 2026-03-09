import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/produto.dart';
import '../providers/produtos_provider.dart';

class ProdutoFormPage extends ConsumerStatefulWidget {
  final String? produtoId;

  const ProdutoFormPage({super.key, this.produtoId});

  @override
  ConsumerState<ProdutoFormPage> createState() => _ProdutoFormPageState();
}

class _ProdutoFormPageState extends ConsumerState<ProdutoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _precoController = TextEditingController();
  final _stockController = TextEditingController();
  
  double _ivaSelec = AppConstants.ivaNormal;
  String _unidadeSelecionada = AppConstants.unidades[0];
  bool _isLoading = false;
  bool _isEditMode = false;
  Produto? _produtoOriginal;

  @override
  void initState() {
    super.initState();
    if (widget.produtoId != null) {
      _isEditMode = true;
      _loadProduto();
    }
  }

  Future<void> _loadProduto() async {
    setState(() => _isLoading = true);
    try {
      final produto = await ref.read(produtosProvider.notifier).getProduto(widget.produtoId!);
      if (produto != null && mounted) {
        _produtoOriginal = produto;
        _nomeController.text = produto.nome;
        _descricaoController.text = produto.descricao;
        _precoController.text = produto.preco.toString();
        _stockController.text = produto.stock.toString();
        _ivaSelec = produto.iva;
        _unidadeSelecionada = produto.unidade;
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _descricaoController.dispose();
    _precoController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Produto' : 'Novo Produto'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome *',
                        prefixIcon: Icon(Icons.inventory),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o nome';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descricaoController,
                      decoration: const InputDecoration(
                        labelText: 'Descrição',
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _precoController,
                      decoration: const InputDecoration(
                        labelText: 'Preço (€) *',
                        prefixIcon: Icon(Icons.euro),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o preço';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Preço inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<double>(
                      value: _ivaSelec,
                      decoration: const InputDecoration(
                        labelText: 'Taxa IVA',
                        prefixIcon: Icon(Icons.percent),
                      ),
                      items: AppConstants.ivaOptions.map((iva) {
                        return DropdownMenuItem(
                          value: iva,
                          child: Text('${iva.toStringAsFixed(0)}%'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _ivaSelec = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _unidadeSelecionada,
                      decoration: const InputDecoration(
                        labelText: 'Unidade',
                        prefixIcon: Icon(Icons.straighten),
                      ),
                      items: AppConstants.unidades.map((unidade) {
                        return DropdownMenuItem(
                          value: unidade,
                          child: Text(unidade),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _unidadeSelecionada = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _stockController,
                      decoration: const InputDecoration(
                        labelText: 'Stock *',
                        prefixIcon: Icon(Icons.inventory_2),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o stock';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Stock inválido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _salvar,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_isEditMode ? 'Atualizar' : 'Criar Produto'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final produto = _isEditMode && _produtoOriginal != null
          ? _produtoOriginal!.copyWith(
              nome: _nomeController.text.trim(),
              descricao: _descricaoController.text.trim(),
              preco: double.parse(_precoController.text),
              iva: _ivaSelec,
              unidade: _unidadeSelecionada,
              stock: int.parse(_stockController.text),
            )
          : Produto(
              id: '',
              nome: _nomeController.text.trim(),
              descricao: _descricaoController.text.trim(),
              preco: double.parse(_precoController.text),
              iva: _ivaSelec,
              unidade: _unidadeSelecionada,
              stock: int.parse(_stockController.text),
            );

      if (_isEditMode) {
        await ref.read(produtosProvider.notifier).updateProduto(produto);
      } else {
        await ref.read(produtosProvider.notifier).addProduto(produto);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Produto atualizado' : 'Produto criado'),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

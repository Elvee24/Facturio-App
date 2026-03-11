import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/i18n/app_text.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../configuracoes/presentation/providers/configuracoes_provider.dart';
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

  String _t(BuildContext context, {required String pt, required String en}) {
    return AppText.tr(context, pt: pt, en: en);
  }

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
    ref.watch(themeProvider); // rebuild on language change
    final colors = Theme.of(context).colorScheme;
    final config = ref.watch(configuracoesProvider).maybeWhen(
          data: (cfg) => cfg,
          orElse: () => null,
        );
    final ivaBase = config?.ivaOptions.isNotEmpty == true ? config!.ivaOptions : AppConstants.ivaOptions;
    final unidadesBase =
        config?.unidades.isNotEmpty == true ? config!.unidades : AppConstants.unidades;
    final ivaDropdownOptions = {...ivaBase, _ivaSelec}.toList()..sort();
    final unidadeDropdownOptions = {...unidadesBase, _unidadeSelecionada}.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode
              ? _t(context, pt: 'Editar Produto', en: 'Edit Product')
              : _t(context, pt: 'Novo Produto', en: 'New Product'),
        ),
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colors.primary, colors.secondary],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditMode
                                ? _t(context, pt: 'Atualizar Produto', en: 'Update Product')
                                : _t(context, pt: 'Novo Produto', en: 'New Product'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: colors.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _t(
                              context,
                              pt: 'Defina preço, IVA e stock para manter a faturação correta.',
                              en: 'Set price, VAT, and stock to keep billing accurate.',
                            ),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: colors.onPrimary.withValues(alpha: 0.9),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _nomeController,
                              decoration: InputDecoration(
                                labelText: _t(context, pt: 'Nome *', en: 'Name *'),
                                prefixIcon: const Icon(Icons.inventory),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return _t(context, pt: 'Por favor, insira o nome', en: 'Please enter a name');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _descricaoController,
                              decoration: InputDecoration(
                                labelText: _t(context, pt: 'Descrição', en: 'Description'),
                                prefixIcon: const Icon(Icons.description),
                              ),
                              maxLines: 3,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _precoController,
                              decoration: InputDecoration(
                                labelText: _t(context, pt: 'Preço (€) *', en: 'Price (€) *'),
                                prefixIcon: const Icon(Icons.euro),
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return _t(context, pt: 'Por favor, insira o preço', en: 'Please enter a price');
                                }
                                if (double.tryParse(value) == null) {
                                  return _t(context, pt: 'Preço inválido', en: 'Invalid price');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<double>(
                              initialValue: _ivaSelec,
                              decoration: InputDecoration(
                                labelText: _t(context, pt: 'Taxa IVA', en: 'VAT Rate'),
                                prefixIcon: const Icon(Icons.percent),
                              ),
                              items: ivaDropdownOptions.map((iva) {
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
                              initialValue: _unidadeSelecionada,
                              decoration: InputDecoration(
                                labelText: _t(context, pt: 'Unidade', en: 'Unit'),
                                prefixIcon: const Icon(Icons.straighten),
                              ),
                              items: unidadeDropdownOptions.map((unidade) {
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
                              decoration: InputDecoration(
                                labelText: _t(context, pt: 'Stock *', en: 'Stock *'),
                                prefixIcon: const Icon(Icons.inventory_2),
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return _t(context, pt: 'Por favor, insira o stock', en: 'Please enter stock');
                                }
                                if (int.tryParse(value) == null) {
                                  return _t(context, pt: 'Stock inválido', en: 'Invalid stock value');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _salvar,
                              icon: const Icon(Icons.save),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              label: Text(
                                _isEditMode
                                    ? _t(context, pt: 'Atualizar', en: 'Update')
                                    : _t(context, pt: 'Criar Produto', en: 'Create Product'),
                              ),
                            ),
                          ],
                        ),
                      ),
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
        UiHelpers.mostrarSnackBar(
          context,
          mensagem: _isEditMode
              ? _t(context, pt: 'Produto atualizado com sucesso', en: 'Product updated successfully')
              : _t(context, pt: 'Produto criado com sucesso', en: 'Product created successfully'),
          tipo: TipoSnackBar.sucesso,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.mostrarSnackBar(
          context,
          mensagem: '${_t(context, pt: 'Erro ao guardar produto', en: 'Error saving product')}: $e',
          tipo: TipoSnackBar.erro,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

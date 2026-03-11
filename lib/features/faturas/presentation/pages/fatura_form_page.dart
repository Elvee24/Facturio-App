import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/i18n/app_text.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/fatura_legal_service.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../../../shared/models/linha_fatura.dart';
import '../../domain/entities/fatura.dart';
import '../../../clientes/presentation/providers/clientes_provider.dart';
import '../../../configuracoes/presentation/providers/configuracoes_provider.dart';
import '../../../produtos/presentation/providers/produtos_provider.dart';
import '../providers/faturas_provider.dart';

class FaturaFormPage extends ConsumerStatefulWidget {
  final String? faturaId;

  const FaturaFormPage({super.key, this.faturaId});

  @override
  ConsumerState<FaturaFormPage> createState() => _FaturaFormPageState();
}

class _FaturaFormPageState extends ConsumerState<FaturaFormPage> {
  String? _clienteSelecionadoId;
  String? _clienteSelecionadoNome;
  String _estadoSelecionado = AppConstants.estadoRascunho;
  String _tipoDocumentoSelecionado = 'Fatura';
  String? _meioPagamentoSelecionado;
  String? _motivoIsencaoIVASelecionado;
  bool _aplicarRetencao = false;
  double _percentagemRetencao = 25.0;
  final List<LinhaFatura> _linhas = [];
  final _clienteNifController = TextEditingController();
  final _clienteMoradaController = TextEditingController();
  final _observacoesController = TextEditingController();

  String _t(BuildContext context, {required String pt, required String en}) {
    return AppText.tr(context, pt: pt, en: en);
  }

  @override
  void dispose() {
    _clienteNifController.dispose();
    _clienteMoradaController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeProvider); // rebuild on language change
    final colors = Theme.of(context).colorScheme;
    final clientesAsync = ref.watch(clientesProvider);
    final produtosAsync = ref.watch(produtosProvider);
    final config = ref.watch(configuracoesProvider).maybeWhen(
          data: (cfg) => cfg,
          orElse: () => null,
        );
    final estados =
        config?.estadosFatura.isNotEmpty == true ? config!.estadosFatura : AppConstants.estadosFatura;
    final estadosDropdown = {...estados, _estadoSelecionado}.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_t(context, pt: 'Nova Fatura', en: 'New Invoice')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
                    _t(context, pt: 'Emissão de Fatura', en: 'Invoice Issuance'),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: colors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _t(
                      context,
                      pt: 'Selecione cliente, estado e adicione linhas de produto.',
                      en: 'Select customer, status, and add product lines.',
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
                    clientesAsync.when(
                      data: (clientes) {
                        return DropdownButtonFormField<String>(
                          initialValue: _clienteSelecionadoId,
                          decoration: InputDecoration(
                            labelText: _t(context, pt: 'Cliente *', en: 'Customer *'),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          hint: Text(_t(context, pt: 'Selecione um cliente', en: 'Select a customer')),
                          items: clientes.map((cliente) {
                            return DropdownMenuItem(
                              value: cliente.id,
                              child: Text(cliente.nome),
                            );
                          }).toList(),
                          onChanged: (value) {
                            final cliente = clientes.firstWhere((c) => c.id == value);
                            setState(() {
                              _clienteSelecionadoId = value;
                              _clienteSelecionadoNome = cliente.nome;
                            });
                          },
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (_, _) => Text(_t(context, pt: 'Erro ao carregar clientes', en: 'Error loading customers')),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _estadoSelecionado,
                      decoration: InputDecoration(
                        labelText: _t(context, pt: 'Estado', en: 'Status'),
                        prefixIcon: const Icon(Icons.info),
                      ),
                      items: estadosDropdown.map((estado) {
                        return DropdownMenuItem(
                          value: estado,
                          child: Text(estado),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _estadoSelecionado = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _t(context, pt: 'Dados do Documento', en: 'Document Details'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    if (config != null)
                      DropdownButtonFormField<String>(
                        initialValue: _tipoDocumentoSelecionado,
                        decoration: InputDecoration(
                          labelText: _t(context, pt: 'Tipo de Documento *', en: 'Document Type *'),
                          prefixIcon: const Icon(Icons.description),
                        ),
                        items: config.tiposDocumento.map((tipo) {
                          return DropdownMenuItem(
                            value: tipo,
                            child: Text(tipo),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _tipoDocumentoSelecionado = value!;
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _clienteNifController,
                      decoration: InputDecoration(
                        labelText: _t(context, pt: 'NIF do Cliente', en: 'Customer Tax ID'),
                        prefixIcon: const Icon(Icons.badge),
                        helperText: _t(context, pt: '9 dígitos (opcional)', en: '9 digits (optional)'),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 9,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _clienteMoradaController,
                      decoration: InputDecoration(
                        labelText: _t(context, pt: 'Morada do Cliente', en: 'Customer Address'),
                        prefixIcon: const Icon(Icons.location_on),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    if (config != null)
                      DropdownButtonFormField<String>(
                        initialValue: _meioPagamentoSelecionado,
                        decoration: InputDecoration(
                          labelText: _t(context, pt: 'Meio de Pagamento', en: 'Payment Method'),
                          prefixIcon: const Icon(Icons.payment),
                        ),
                        hint: Text(_t(context, pt: 'Selecione um meio de pagamento', en: 'Select a payment method')),
                        items: config.meiosPagamento.map((meio) {
                          return DropdownMenuItem(
                            value: meio,
                            child: Text(meio),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _meioPagamentoSelecionado = value;
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _aplicarRetencao,
                      title: Text(_t(context, pt: 'Aplicar Retenção na Fonte', en: 'Apply Withholding Tax')),
                      subtitle: _aplicarRetencao
                          ? Text('${_percentagemRetencao.toStringAsFixed(1)}%')
                          : null,
                      onChanged: (value) {
                        setState(() {
                          _aplicarRetencao = value ?? false;
                        });
                      },
                    ),
                    if (_aplicarRetencao)
                      Slider(
                        value: _percentagemRetencao,
                        min: 0,
                        max: 50,
                        divisions: 50,
                        label: '${_percentagemRetencao.toStringAsFixed(1)}%',
                        onChanged: (value) {
                          setState(() {
                            _percentagemRetencao = value;
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: _motivoIsencaoIVASelecionado,
                      decoration: InputDecoration(
                        labelText: _t(context, pt: 'Motivo de Isenção de IVA', en: 'VAT Exemption Reason'),
                        prefixIcon: const Icon(Icons.discount),
                        helperText: _t(context, pt: 'Apenas se aplicável', en: 'Only if applicable'),
                      ),
                      hint: Text(_t(context, pt: 'Nenhum', en: 'None')),
                      items: AppConstants.motivosIsencaoIVA.map((motivo) {
                        return DropdownMenuItem(
                          value: motivo,
                          child: Text(
                            motivo.length > 60 ? '${motivo.substring(0, 60)}...' : motivo,
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _motivoIsencaoIVASelecionado = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _observacoesController,
                      decoration: InputDecoration(
                        labelText: _t(context, pt: 'Observações', en: 'Notes'),
                        prefixIcon: const Icon(Icons.note),
                        helperText: _t(context, pt: 'Informações adicionais para a fatura', en: 'Additional information for the invoice'),
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () => _mostrarDialogoProduto(produtosAsync.value ?? []),
                      icon: const Icon(Icons.add),
                      label: Text(_t(context, pt: 'Adicionar Produto', en: 'Add Product')),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _t(context, pt: 'Produtos/Serviços', en: 'Products/Services'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            if (_linhas.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_t(context, pt: 'Nenhum produto adicionado', en: 'No product added')),
                ),
              )
            else
              ..._linhas.asMap().entries.map((entry) {
                final index = entry.key;
                final linha = entry.value;
                return Card(
                  child: ListTile(
                    title: Text(linha.produtoNome),
                    subtitle: Text(
                      '${_t(context, pt: 'Qtd', en: 'Qty')}: ${linha.quantidade} | €${linha.total.toStringAsFixed(2)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _linhas.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              }),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _linhas.isEmpty || _clienteSelecionadoId == null
                  ? null
                  : _criarFatura,
              icon: const Icon(Icons.receipt_long),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              label: Text(_t(context, pt: 'Criar Fatura', en: 'Create Invoice')),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoProduto(List produtos) {
    String? produtoSelecionadoId;
    final quantidadeController = TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_t(context, pt: 'Adicionar Produto', en: 'Add Product')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField(
              hint: Text(_t(context, pt: 'Selecione um produto', en: 'Select a product')),
              items: produtos.map((produto) {
                return DropdownMenuItem(
                  value: produto.id,
                  child: Text('${produto.nome} - €${produto.preco}'),
                );
              }).toList(),
              onChanged: (value) {
                produtoSelecionadoId = value as String?;
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantidadeController,
              decoration: InputDecoration(
                labelText: _t(context, pt: 'Quantidade', en: 'Quantity'),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_t(context, pt: 'Cancelar', en: 'Cancel')),
          ),
          TextButton(
            onPressed: () {
              if (produtoSelecionadoId != null) {
                final produto = produtos.firstWhere((p) => p.id == produtoSelecionadoId);
                final quantidade = double.tryParse(quantidadeController.text) ?? 1;
                
                setState(() {
                  _linhas.add(LinhaFatura.fromProduto(produto, quantidade));
                });
              }
              Navigator.pop(context);
            },
            child: Text(_t(context, pt: 'Adicionar', en: 'Add')),
          ),
        ],
      ),
    );
  }

  Future<void> _criarFatura() async {
    if (_clienteSelecionadoId == null || _clienteSelecionadoNome == null) {
      return;
    }

    try {
      // Obter configuração para série e tipo de documento
      final configAsync = ref.read(configuracoesProvider);
      final config = configAsync.value;
      
      if (config == null) {
        throw Exception('Configuração da empresa não disponível');
      }

      // Validar NIF do cliente se foi preenchido
      final clienteNif = _clienteNifController.text.trim();
      if (clienteNif.isNotEmpty && !FaturaLegalService.validarNIF(clienteNif)) {
        UiHelpers.mostrarSnackBar(
          context,
          mensagem: _t(
            context,
            pt: 'NIF do cliente inválido. Deve ter 9 dígitos válidos.',
            en: 'Invalid customer tax ID. It must contain 9 valid digits.',
          ),
          tipo: TipoSnackBar.erro,
        );
        return;
      }

      // Calcular valores
      final subtotal = _linhas.fold<double>(0, (sum, linha) => sum + linha.total);
      double? valorRetencao;
      if (_aplicarRetencao) {
        valorRetencao = FaturaLegalService.calcularRetencao(
          valorBase: subtotal,
          taxaRetencao: _percentagemRetencao,
        );
      }

      final fatura = Fatura(
        id: '',
        numero: '',
        data: DateTime.now(),
        clienteId: _clienteSelecionadoId!,
        clienteNome: _clienteSelecionadoNome!,
        linhas: _linhas,
        estado: _estadoSelecionado,
        tipoDocumento: _tipoDocumentoSelecionado,
        serie: config.serieAtual,
        dataCriacao: DateTime.now(),
        clienteNif: clienteNif.isEmpty ? null : clienteNif,
        clienteMorada: _clienteMoradaController.text.trim().isEmpty 
            ? null 
            : _clienteMoradaController.text.trim(),
        meioPagamento: _meioPagamentoSelecionado,
        retencaoFonte: _aplicarRetencao ? _percentagemRetencao : null,
        valorRetencao: valorRetencao,
        motivoIsencaoIVA: _motivoIsencaoIVASelecionado,
        observacoes: _observacoesController.text.trim().isEmpty 
            ? null 
            : _observacoesController.text.trim(),
      );

      await ref.read(faturasProvider.notifier).addFatura(fatura);

      if (mounted) {
        UiHelpers.mostrarSnackBar(
          context,
          mensagem: _t(context, pt: 'Fatura criada com sucesso', en: 'Invoice created successfully'),
          tipo: TipoSnackBar.sucesso,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.mostrarSnackBar(
          context,
          mensagem: '${_t(context, pt: 'Erro ao criar fatura', en: 'Error creating invoice')}: $e',
          tipo: TipoSnackBar.erro,
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/i18n/app_text.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/fatura_legal_service.dart';
import '../../../../core/utils/ui_helpers.dart';
import '../../domain/entities/cliente.dart';
import '../providers/clientes_provider.dart';

class ClienteFormPage extends ConsumerStatefulWidget {
  final String? clienteId;

  const ClienteFormPage({super.key, this.clienteId});

  @override
  ConsumerState<ClienteFormPage> createState() => _ClienteFormPageState();
}

class _ClienteFormPageState extends ConsumerState<ClienteFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _nifController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _moradaController = TextEditingController();
  
  bool _isLoading = false;
  bool _isEditMode = false;
  Cliente? _clienteOriginal;

  String _t(BuildContext context, {required String pt, required String en}) {
    return AppText.tr(context, pt: pt, en: en);
  }

  @override
  void initState() {
    super.initState();
    if (widget.clienteId != null) {
      _isEditMode = true;
      _loadCliente();
    }
  }

  Future<void> _loadCliente() async {
    setState(() => _isLoading = true);
    try {
      final cliente = await ref.read(clientesProvider.notifier).getCliente(widget.clienteId!);
      if (cliente != null && mounted) {
        _clienteOriginal = cliente;
        _nomeController.text = cliente.nome;
        _nifController.text = cliente.nif;
        _emailController.text = cliente.email;
        _telefoneController.text = cliente.telefone;
        _moradaController.text = cliente.morada;
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
    _nifController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _moradaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(themeProvider); // rebuild on language change
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode
              ? _t(context, pt: 'Editar Cliente', en: 'Edit Customer')
              : _t(context, pt: 'Novo Cliente', en: 'New Customer'),
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
                                ? _t(context, pt: 'Atualizar Cliente', en: 'Update Customer')
                                : _t(context, pt: 'Novo Cliente', en: 'New Customer'),
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: colors.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _t(
                              context,
                              pt: 'Preencha os dados para manter o cadastro organizado.',
                              en: 'Fill in the details to keep records organized.',
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
                                prefixIcon: const Icon(Icons.person),
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
                              controller: _nifController,
                              decoration: InputDecoration(
                                labelText: _t(context, pt: 'NIF *', en: 'Tax ID *'),
                                prefixIcon: const Icon(Icons.badge),
                                helperText: _t(context, pt: '9 dígitos — pessoa singular (1,2,3), coletiva (5,6,7,8,9)', en: '9 digits — individual (1,2,3), company (5,6,7,8,9)'),
                              ),
                              keyboardType: TextInputType.number,
                              maxLength: 9,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return _t(context, pt: 'Por favor, insira o NIF', en: 'Please enter a tax ID');
                                }
                                if (!FaturaLegalService.validarNIF(value.trim())) {
                                  return _t(context, pt: 'NIF inválido. Verifique os 9 dígitos e o dígito de controlo.', en: 'Invalid tax ID. Check the 9 digits and check digit.');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: _t(context, pt: 'Email', en: 'Email'),
                                prefixIcon: const Icon(Icons.email),
                                helperText: _t(context, pt: 'Exemplo: nome@empresa.pt', en: 'Example: name@company.com'),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) return null;
                                if (!FaturaLegalService.validarEmail(value.trim())) {
                                  return _t(context, pt: 'Email inválido. Use o formato nome@dominio.pt', en: 'Invalid email. Use format name@domain.com');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _telefoneController,
                              decoration: InputDecoration(
                                labelText: _t(context, pt: 'Telefone', en: 'Phone'),
                                prefixIcon: const Icon(Icons.phone),
                                helperText: _t(context, pt: 'Exemplo: 912345678 ou +351212345678', en: 'Example: 912345678 or +351212345678'),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                if (value == null || value.isEmpty) return null;
                                final r = FaturaLegalService.validarTelefoneComMensagem(value.trim());
                                return r.valido ? null : _t(context, pt: r.erro!, en: r.erro!);
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _moradaController,
                              decoration: InputDecoration(
                                labelText: _t(context, pt: 'Morada', en: 'Address'),
                                prefixIcon: const Icon(Icons.location_on),
                              ),
                              maxLines: 3,
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
                                    : _t(context, pt: 'Criar Cliente', en: 'Create Customer'),
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
      final cliente = _isEditMode && _clienteOriginal != null
          ? _clienteOriginal!.copyWith(
              nome: _nomeController.text.trim(),
              nif: _nifController.text.trim(),
              email: _emailController.text.trim(),
              telefone: _telefoneController.text.trim(),
              morada: _moradaController.text.trim(),
            )
          : Cliente(
              id: '',
              nome: _nomeController.text.trim(),
              nif: _nifController.text.trim(),
              email: _emailController.text.trim(),
              telefone: _telefoneController.text.trim(),
              morada: _moradaController.text.trim(),
              dataCriacao: DateTime.now(),
            );

      if (_isEditMode) {
        await ref.read(clientesProvider.notifier).updateCliente(cliente);
      } else {
        await ref.read(clientesProvider.notifier).addCliente(cliente);
      }

      if (mounted) {
        UiHelpers.mostrarSnackBar(
          context,
          mensagem: _isEditMode
              ? _t(context, pt: 'Cliente atualizado com sucesso', en: 'Customer updated successfully')
              : _t(context, pt: 'Cliente criado com sucesso', en: 'Customer created successfully'),
          tipo: TipoSnackBar.sucesso,
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        UiHelpers.mostrarSnackBar(
          context,
          mensagem: '${_t(context, pt: 'Erro ao guardar cliente', en: 'Error saving customer')}: $e',
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Editar Cliente' : 'Novo Cliente'),
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
                        prefixIcon: Icon(Icons.person),
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
                      controller: _nifController,
                      decoration: const InputDecoration(
                        labelText: 'NIF *',
                        prefixIcon: Icon(Icons.badge),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, insira o NIF';
                        }
                        if (value.length != 9) {
                          return 'NIF deve ter 9 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (!value.contains('@')) {
                            return 'Email inválido';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _telefoneController,
                      decoration: const InputDecoration(
                        labelText: 'Telefone',
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _moradaController,
                      decoration: const InputDecoration(
                        labelText: 'Morada',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _salvar,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(_isEditMode ? 'Atualizar' : 'Criar Cliente'),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditMode ? 'Cliente atualizado' : 'Cliente criado'),
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

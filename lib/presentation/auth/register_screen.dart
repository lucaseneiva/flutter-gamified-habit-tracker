import 'package:firy_streak/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authRepository = ref.read(authRepositoryProvider);

    try {
      authRepository.signUp(
        _emailController.text,
        _confirmPasswordController.text,
      );

      if (mounted && Navigator.canPop(context)) {
        Navigator.of(
          context,
        ).pop(); // Volta para LoginScreen, que será substituída por HomeScreen
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cadastro realizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'A senha fornecida é muito fraca.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Este e-mail já está em uso.';
      } else if (e.code == 'invalid-email') {
        message = 'O formato do e-mail é inválido.';
      } else {
        message = 'Ocorreu um erro. Tente novamente.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ocorreu um erro inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(80.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _RegisterHeader(),

                  const SizedBox(height: 30),

                  _RegisterFormInputs(
                    emailController: _emailController,
                    passwordController: _passwordController,
                    confirmPasswordController: _confirmPasswordController,
                  ),
                  const SizedBox(height: 16),

                  _RegisterActions(
                    isLoading: _isLoading,
                    signUp: _signUp,
                    onNavigateToLogin: () {
                      Navigator.of(
                        context,
                      ).pop(); // Voltar para a tela de Login
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegisterFormInputs extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  const _RegisterFormInputs({
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira um email';
            }
            if (!value.contains('@')) {
              return 'Email inválido';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          decoration: const InputDecoration(labelText: 'Senha'),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira uma senha';
            }
            if (value.length < 6) {
              return 'A senha deve ter no mínimo 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: confirmPasswordController,
          decoration: const InputDecoration(labelText: 'Confirmar Senha'),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, confirme sua senha';
            }
            if (value != passwordController.text) {
              return 'As senhas não coincidem';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _RegisterHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Crie sua conta!',
      style: Theme.of(context).textTheme.headlineSmall,
      textAlign: TextAlign.center,
    );
  }
}

class _RegisterActions extends StatelessWidget {
  final bool isLoading;
  final VoidCallback signUp;
  final VoidCallback onNavigateToLogin;

  const _RegisterActions({
    required this.isLoading,
    required this.signUp,
    required this.onNavigateToLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(onPressed: signUp, child: const Text('Cadastrar')),
        SizedBox(height: 16),
        TextButton(
          onPressed: onNavigateToLogin,
          child: const Text('Já tem uma conta? Faça login'),
        ),
      ],
    );
  }
}

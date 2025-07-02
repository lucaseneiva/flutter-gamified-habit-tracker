// lib/login_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_screen.dart'; // Para navegar para a tela de registro

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // A navegação para HomeScreen será feita pelo AuthGate
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'Nenhum usuário encontrado para este e-mail.';
      } else if (e.code == 'wrong-password') {
        message = 'Senha incorreta.';
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login - Firy Streak')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(80.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _LoginHeader(),

                  const SizedBox(height: 24),

                  _LoginFormInputs(
                    emailController: _emailController,
                    passwordController: _passwordController,
                  ),

                  const SizedBox(height: 24),

                  _LoginActions(
                    isLoading: _isLoading,
                    signIn: _signIn,
                    onNavigateToRegister: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
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

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Text(
      'Seja bem vindo novamente!!',
      style: Theme.of(context).textTheme.headlineSmall,
      textAlign: TextAlign.center,
    );
  }
}

class _LoginFormInputs extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const _LoginFormInputs({
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextFormField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor, insira seu email';
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
              return 'Por favor, insira sua senha';
            }
            return null;
          },
        ),
      ],
    );
  }
}

class _LoginActions extends StatelessWidget {
  final bool isLoading;
  final VoidCallback signIn;
  final VoidCallback onNavigateToRegister;

  const _LoginActions({
    required this.isLoading,
    required this.signIn,
    required this.onNavigateToRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        isLoading
            ? const Center(child: CircularProgressIndicator())
            : ElevatedButton(onPressed: signIn, child: const Text('Entrar')),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
          onPressed: onNavigateToRegister,
          child: const Text('Não tem uma conta? Cadastre-se', textAlign: TextAlign.center,),
        ),
        )
        
      ],
    );
  }
}

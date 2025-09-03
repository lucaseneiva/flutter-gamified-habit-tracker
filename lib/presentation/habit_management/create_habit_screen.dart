import 'package:firy_streak/presentation/providers/habit_providers.dart';
import 'package:firy_streak/data/repositories/habit_repository_impl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CreateHabitScreen extends ConsumerStatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  ConsumerState<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends ConsumerState<CreateHabitScreen> {
  final _habitController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedHabit = 'Estudar';
  bool _isLoading = false;

  @override
  void dispose() {
    _habitController.dispose();
    super.dispose();
  }

  void _startHabit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final HabitRepositoryImpl habitRepository = ref.read(habitRepositoryImplProvider);

        await habitRepository.createHabit(_selectedHabit.toString());
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar o hábito: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 360),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 2),
                    Text(
                      'Qual hábito você\nquer criar?',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.nunito(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SvgPicture.asset('assets/firy_thinking.svg', height: 150),
                    const SizedBox(height: 40),

                    // Input de Hábito
                    Row(
                      children: [
                        const Text('Eu quero', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 195),
                            child: DropdownButtonFormField<String>(
                              value: _selectedHabit,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                hintText: 'Escolha um hábito',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              items:
                                  [
                                    'Estudar',
                                    'Ler',
                                    'Meditar',
                                    'Exercitar-se',
                                    'Beber água',
                                  ].map((habit) {
                                    return DropdownMenuItem<String>(
                                      value: habit,
                                      child: Text(
                                        habit,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedHabit = value;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Selecione um hábito!';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    const Text('todos os dias', style: TextStyle(fontSize: 18)),

                    const Spacer(flex: 3),

                    // Botão Iniciar
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _startHabit,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: const Color(0xFFF9703B),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Criar',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

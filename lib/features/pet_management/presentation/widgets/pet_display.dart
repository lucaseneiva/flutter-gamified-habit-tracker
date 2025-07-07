import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firy_streak/features/pet_management/domain/pet_state.dart';

class PetDisplay extends StatelessWidget {
  final PetState petState;
  final VoidCallback onFeedPet;

  const PetDisplay({
    super.key,
    required this.petState,
    required this.onFeedPet,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: SvgPicture.asset(petState.imagePath, height: 120),
          ),

          Spacer(flex: 1),
          // Botão
          ElevatedButton(
            onPressed: (!petState.isFed || petState.isEgg || petState.isDead)
                ? () => _showConfirmationDialog(context, petState)
                : null,
            child: Text(
              petState.isDead
                  ? "Reviver o Bichinho"
                  : petState.isEgg
                  ? "Chocar"
                  : "Alimentar",
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmationDialog(BuildContext context, PetState currentState) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(currentState.isDead ? "✧ Reviver ✧" : "🪵 Alimentar 🪵"),
              const SizedBox(height: 16),
              Text(
                currentState.isDead
                    ? "Quer mesmo reviver seu companheiro?"
                    : "Vai dar comida pro bichinho agora?",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Colors.grey),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Não"),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9703B),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      onFeedPet();
                    },
                    child: const Text("Sim"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firy_streak/domain/models/pet_state.dart';
import 'package:firy_streak/presentation/core/utils/confirmation_dialog.dart';

class PetDisplay extends StatelessWidget {
  final PetState petState;
  final VoidCallback onCheckIn;

  const PetDisplay({
    super.key,
    required this.petState,
    required this.onCheckIn,
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
          ElevatedButton(
            onPressed: petState.isFed || petState.isJustFed
                ? null
                : () => showDialog(
                    context: context,
                    builder: (context) => ConfirmationDialog(
                      message: petState.isDead
                          ? "Quer mesmo reviver seu companheiro?"
                          : "Vai dar comida pra Chaminha agora?",
                      title: petState.isDead ? "Reviver" : "Alimentar",
                      onConfirmation: onCheckIn,
                    ),
                  ),
            child: Text(petState.isDead ? "Reviver a Chaminha" : "Alimentar"),
          ),
        ],
      ),
    );
  }
}

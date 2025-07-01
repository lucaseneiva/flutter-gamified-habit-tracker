import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firy_streak/features/pet_management/presentation/widgets/speech_bubble.dart';

class PetDisplay extends StatelessWidget {
  final String petState;

  const PetDisplay({
    super.key,
    required this.petState
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260, // Altura total para acomodar pet + bubble
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pet image no centro-inferior
          Positioned(
            bottom: 0,
            child: _buildPetImage(petState),
          ),
          // Speech bubble no topo, só aparece quando precisa alimentar
          if (petState == 'NOT_FED' || petState == 'EGG')
            Positioned(
              top: 0,
              child: SpeechBubble(
                message: _getBubbleMessage(petState),
                bubbleColor: Colors.white,
                borderColor: const Color(0xFFE0E0E0),
                textColor: const Color(0xFF4F4F4F),
              ),
            ),
        ],
      ),
    );
  }

   String _getBubbleMessage(String state) {
    switch (state) {
      case 'NOT_FED': return 'Estou com fome!';
      case 'EGG': return 'Me choca!';
      default: return '';
    }
  }

  Widget _buildPetImage(String state) {
    String svgAssetPath;

    if (state.contains('_')) {
      final parts = state.split('_');
      final growthStage = parts[0].toLowerCase(); // baby, child, teen, adult
      final feedingStatus = parts[1].toLowerCase(); // fed, not_fed

      // A primeira fase usa os SVGs antigos para não quebrar o que já existe
      if (growthStage == 'baby') {
        svgAssetPath = 'assets/${feedingStatus == 'fed' ? 'fed' : 'not_fed'}.svg';
      } else {
        // As novas fases usam o padrão "stage_status.svg"
        svgAssetPath = 'assets/${growthStage}_$feedingStatus.svg';
      }
    } else {
      // Lida com os estados simples que não têm estágio (Ovo, Morto)
      switch (state) {
        case 'EGG':
          svgAssetPath = 'assets/egg.svg';
          break;
        case 'DEAD':
          svgAssetPath = 'assets/dead.svg';
          break;
        default:
          // Fallback para qualquer estado inesperado
          svgAssetPath = 'assets/egg.svg';
      }
    }
    return SvgPicture.asset(svgAssetPath, height: 200,);
  }
}


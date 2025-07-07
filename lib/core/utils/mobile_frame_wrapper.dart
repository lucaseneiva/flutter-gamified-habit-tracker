import 'package:flutter/material.dart';

class MobileFrameWrapper extends StatelessWidget {
  final Widget child;

  const MobileFrameWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF2E2E2E);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Container(
          // Define a largura máxima do nosso "celular".
          constraints: const BoxConstraints(
            maxWidth: 480,
          ),
          child: AspectRatio(
            aspectRatio: 9/20,
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40)
                ),
                // corta o conteúdo do app para que ele se encaixe nos cantos arredondados
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: child, // <-- AQUI ENTRA A TELA DO APP!
                ),
              ),
          ),
        ),
      ),
    );
  }
}
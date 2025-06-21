import 'package:flutter/material.dart';

class SpeechBubble extends StatelessWidget {
  final String message;
  final Color bubbleColor;
  final Color borderColor;
  final Color textColor;

  const SpeechBubble({
    super.key,
    required this.message,
    this.bubbleColor = Colors.white,
    this.borderColor = Colors.grey,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubbleWithTailPainter(
        bubbleColor: bubbleColor,
        borderColor: borderColor,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 18), // espaço para a setinha
        child: Text(
          message,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class BubbleWithTailPainter extends CustomPainter {
  final Color bubbleColor;
  final Color borderColor;

  BubbleWithTailPainter({
    required this.bubbleColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double tailHeight = 10;
    const double tailWidth = 12;
    const double radius = 20;

    final Paint fillPaint = Paint()
      ..color = bubbleColor
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 💥 INVADIR 1px a área da seta resolve o problema visual
    final RRect bubbleRect = RRect.fromLTRBR(
      0,
      0,
      size.width,
      size.height - tailHeight + 1,
      const Radius.circular(radius),
    );

    // Caminho de preenchimento (bolha + seta)
    final Path fillPath = Path()
      ..moveTo(size.width / 2 - tailWidth / 2, size.height - tailHeight)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 + tailWidth / 2, size.height - tailHeight)
      ..close();

    canvas.drawRRect(bubbleRect, borderPaint);

    canvas.drawPath(fillPath, fillPaint);
    // // Desenha a borda do balão

    // Borda só nas laterais da seta (não no topo dela)
    final Path tailBorder = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 - tailWidth / 2, size.height - tailHeight)
      ..moveTo(size.width / 2, size.height)
      ..lineTo(size.width / 2 + tailWidth / 2, size.height - tailHeight);

    canvas.drawPath(tailBorder, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firy_streak/core/theme/app_colors.dart';

class StreakCard extends StatelessWidget {
  final int streakCount;

  const StreakCard({super.key, required this.streakCount});

  @override
  Widget build(BuildContext context) {
    // Cores do design
    final Color primaryOrange = const Color(0xFFF9703B);
    final Color lightGray = const Color(0xFFE0E0E0);
    final Color darkGrayText = const Color(0xFF4F4F4F);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: AppColors.lightGrey, width: 4),
          boxShadow: [
            BoxShadow(
              color: lightGray,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Streak',
              style: GoogleFonts.nunito(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: darkGrayText,
              ),
            ),
            const SizedBox(height: 6),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$streakCount',
                  style: GoogleFonts.nunito(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: primaryOrange,
                  ),
                ),
                const SizedBox(width: 6),

                Text(
                  streakCount == 1 ? 'dia' : 'dias',
                  style: GoogleFonts.nunito(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: primaryOrange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firy_streak/core/theme/app_colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HabitNameCard extends StatelessWidget {
  final String habitName;

  const HabitNameCard({super.key, required this.habitName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16), // reduzi
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ), // reduzi
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(color: AppColors.lightGrey, width: 4),
          boxShadow: [
            BoxShadow(color: AppColors.lightGrey, offset: const Offset(0, 4)),
          ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset('assets/aim.svg', height: 24),
                  const SizedBox(width: 6),
                  Text(
                    "Hábito",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
              Center(child: Text(habitName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400))),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ThemeCard extends StatelessWidget {
  final String image;
  final bool selected;
  final VoidCallback onTap;

  const ThemeCard({
    super.key,
    required this.image,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),

        width: 130,
        height: 180,

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: selected
                ? Colors.greenAccent
                : Colors.white.withValues(alpha: 0.35),
            width: 3,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),

          child: Stack(
            fit: StackFit.expand,
            children: [

              Image.asset(
                image,
                fit: BoxFit.cover,
              ),

              if (selected)
                Container(
                  color: Colors.green.withValues(alpha: 0.18),
                ),

              if (selected)
                const Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.check_circle,
                      color: Colors.greenAccent,
                      size: 28,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
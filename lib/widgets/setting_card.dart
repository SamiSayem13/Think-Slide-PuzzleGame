import 'package:flutter/material.dart';

class SettingCard extends StatelessWidget {
  final String title;
  final Widget child;

  const SettingCard({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),

        color: Colors.black.withValues(alpha: 0.35),

        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 12),

          child,
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';

class TranslationDirectionSwitcher extends StatelessWidget {
  final VoidCallback onSwitch;
  final String direction;

  const TranslationDirectionSwitcher({
    super.key,
    required this.onSwitch,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Changer de direction',
      child: GestureDetector(
        onTap: onSwitch,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.swap_vert,
              color: Colors.grey[700],
            ),
          ),
        ),
      ),
    );
  }
}
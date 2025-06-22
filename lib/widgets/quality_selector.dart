import 'package:flutter/material.dart';

import '../constants.dart';

class QualitySelector extends StatelessWidget {
  final String quality;
  final ValueChanged<String> onQualityChanged;

  const QualitySelector({
    super.key,
    required this.quality,
    required this.onQualityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildQualityOption('Rapide', 'fast', context),
          const SizedBox(width: AppConstants.smallPadding),
          _buildQualityOption('Équilibrée', 'balanced', context),
          const SizedBox(width: AppConstants.smallPadding),
          _buildQualityOption('Meilleure', 'best', context),
        ],
      ),
    );
  }

  Widget _buildQualityOption(String text, String value, BuildContext context) {
    final isSelected = quality == value;

    return ChoiceChip(
      label: Text(text),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onQualityChanged(value);
        }
      },
      backgroundColor: Colors.transparent,
      selectedColor: const Color(0xFF1A73E8).withOpacity(0.1),
      labelStyle: TextStyle(
        color: isSelected ? const Color(0xFF1A73E8) : Theme.of(context).colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? const Color(0xFF1A73E8) : Colors.grey[300]!,
        ),
      ),
    );
  }
}
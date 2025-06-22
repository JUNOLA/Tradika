import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants.dart';

class SocialIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const SocialIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: IconButton(icon: FaIcon(icon), iconSize: 34, onPressed: onTap),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

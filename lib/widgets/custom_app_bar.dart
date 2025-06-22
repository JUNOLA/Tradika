import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradika/providers/translation_provider.dart';
import '../constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final isConnected = Provider.of<TranslationProvider>(context).apiConnected;

    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Image.asset(
            'assets/images/tradika.png',
            width: AppConstants.iconSizeMedium,
            height: AppConstants.iconSizeMedium,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.translate, color: Color(0xFF1A73E8));
            },
          ),
          const SizedBox(width: AppConstants.smallPadding),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tradika',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              Text('Bassa ↔ Français', style: TextStyle(fontSize: 12)),
              const SizedBox(width: AppConstants.smallPadding),
            ],
          ),
          Icon(
            isConnected ? Icons.wifi : Icons.wifi_off,
            color: isConnected ? Colors.green : Colors.red,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: () => Navigator.pushNamed(context, '/history'),
          tooltip: 'Historique',
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () => Navigator.pushNamed(context, '/settings'),
          tooltip: 'Paramètres',
        ),
      ],
      elevation: 2,
    );
  }
}

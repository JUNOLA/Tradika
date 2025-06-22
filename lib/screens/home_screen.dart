import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradika/providers/translation_provider.dart';
import 'package:tradika/widgets/custom_app_bar.dart';
import 'package:tradika/widgets/input_section.dart';
import 'package:tradika/widgets/output_section.dart';
import '../constants.dart';
import '../widgets/translation_direction_selector.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TranslationProvider _provider;
  bool _showConnectionSnackbar = true;

  @override
  void initState() {
    super.initState();
    _provider = Provider.of<TranslationProvider>(context, listen: false);

    // Écouter les changements de connexion
    _provider.connectionStream.stream.listen((isConnected) {
      if (_showConnectionSnackbar) {
        _showConnectionStatus(isConnected);
      }
    });
  }

  void _showConnectionStatus(bool isConnected) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
            ),
            const SizedBox(width: AppConstants.smallPadding),
            Text(
              isConnected ? 'Connecté à l\'API' : 'Déconnecté de l\'API',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: isConnected ? Colors.green : Colors.red,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppConstants.mediumPadding),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.smallRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Désactiver le redimensionnement automatique
      appBar: const CustomAppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeScreen = constraints.maxWidth > 800;
          final isSmallScreen = constraints.maxWidth < 400;

          return Consumer<TranslationProvider>(
            builder: (context, provider, child) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen
                      ? AppConstants.smallPadding
                      : AppConstants.mediumPadding,
                  vertical: isSmallScreen
                      ? AppConstants.smallPadding
                      : AppConstants.mediumPadding,
                ),
                child: isLargeScreen
                    ? _buildDesktopLayout(provider)
                    : _buildMobileLayout(provider, isSmallScreen),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDesktopLayout(TranslationProvider provider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section d'entrée
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              child: InputSection(provider: provider),
            ),
          ),
        ),

        // Bouton de commutation
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.mediumPadding,
            vertical: AppConstants.largePadding,
          ),
          child: TranslationDirectionSwitcher(
            onSwitch: provider.switchDirection,
            direction: provider.direction,
          ),
        ),

        // Section de sortie
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.mediumPadding),
              child: OutputSection(provider: provider),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(TranslationProvider provider, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section d'entrée avec hauteur limitée
        Card(
          child: Padding(
            padding: EdgeInsets.all(
              isSmallScreen
                  ? AppConstants.smallPadding
                  : AppConstants.mediumPadding,
            ),
            child: InputSection(provider: provider),
          ),
        ),

        // Bouton de commutation
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.mediumPadding),
          child: Center(
            child: TranslationDirectionSwitcher(
              onSwitch: provider.switchDirection,
              direction: provider.direction,
            ),
          ),
        ),

        // Section de sortie avec hauteur limitée
        Expanded(
          flex: 5, // Prend 50% de l'espace disponible
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(
                isSmallScreen
                    ? AppConstants.smallPadding
                    : AppConstants.mediumPadding,
              ),
              child: OutputSection(provider: provider),
            ),
          ),
        ),
      ],
    );
  }
}
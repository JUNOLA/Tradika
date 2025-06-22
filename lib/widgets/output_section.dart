import 'package:flutter/material.dart';
import 'package:tradika/providers/translation_provider.dart';
import '../constants.dart';

class OutputSection extends StatelessWidget {
  final TranslationProvider provider;

  const OutputSection({super.key, required this.provider});

  String _getQualityText() {
    switch (provider.quality) {
      case 'fast':
        return 'Rapide';
      case 'balanced':
        return 'Équilibrée';
      case 'best':
        return 'Meilleure';
      default:
        return 'Rapide';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Résultat de traduction
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppConstants.mediumPadding),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color ?? Colors.grey[100],
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            ),
            child:
                provider.isLoading
                    ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1A73E8),
                            ),
                          ),
                          SizedBox(height: AppConstants.mediumPadding),
                          Text('Traduction en cours...'),
                        ],
                      ),
                    )
                    : SingleChildScrollView(
                      child: Text(
                        provider.outputText,
                        style: const TextStyle(fontSize: 16, height: 1.6),
                      ),
                    ),
          ),
        ),

        // Info de traduction
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppConstants.mediumPadding,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qualité: ${_getQualityText()}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              Text(
                'Temps: ${provider.translationTime}',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        // Section de correction
        if (provider.showCorrectionSection) ...[
          const Divider(height: AppConstants.largePadding),
          const Text(
            'Suggérer une meilleure traduction ?',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          TextField(
            controller: provider.correctionController,
            maxLines: 2,
            minLines: 1,
            decoration: InputDecoration(
              hintText: 'Entrez votre suggestion...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Theme.of(context).cardTheme.color ?? Colors.grey[100],
              contentPadding: const EdgeInsets.all(AppConstants.mediumPadding),
            ),
          ),
          const SizedBox(height: AppConstants.mediumPadding),
          ElevatedButton(
            onPressed: () => provider.submitCorrection(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).cardTheme.color,
              foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.mediumPadding,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.smallRadius),
              ),
            ),
            child: const Text('SOUMETTRE LA CORRECTION'),
          ),
        ],
      ],
    );
  }
}

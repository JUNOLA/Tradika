import 'package:flutter/material.dart';
import 'package:tradika/providers/translation_provider.dart';
import 'package:tradika/widgets/quality_selector.dart';
import '../constants.dart';

class InputSection extends StatelessWidget {
  final TranslationProvider provider;

  const InputSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sélecteur de qualité
        QualitySelector(
          quality: provider.quality,
          onQualityChanged: (newQuality) {
            provider.setQuality(newQuality);
          },
        ),
        const SizedBox(height: AppConstants.mediumPadding),

        // Champ de texte
        TextField(
          controller: provider.inputController,
          maxLines: 5,
          minLines: 3,
          decoration: InputDecoration(
            hintText:
                provider.direction == 'fr→bs'
                    ? 'Entrez votre texte en français...'
                    : 'Entrez votre texte en bassa...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Theme.of(context).cardTheme.color ?? Colors.grey[100],
            contentPadding: const EdgeInsets.all(AppConstants.mediumPadding),
            suffixIcon:
                provider.inputController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        provider.inputController.clear();
                      },
                    )
                    : null,
          ),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: AppConstants.mediumPadding),

        // Bouton de traduction
        ElevatedButton(
          onPressed: provider.isLoading ? null : provider.translate,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: AppConstants.mediumPadding,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.smallRadius),
            ),
          ),
          child:
              provider.isLoading
                  ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : const Text('TRADUIRE', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}

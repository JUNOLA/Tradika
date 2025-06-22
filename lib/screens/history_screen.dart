import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradika/models/translation.dart';
import 'package:tradika/providers/translation_provider.dart';
import '../constants.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TranslationProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Effacer l\'historique'),
                      content: const Text(
                        'Voulez-vous vraiment effacer tout l\'historique des traductions?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            provider.clearHistory();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Historique effacé'),
                              ),
                            );
                          },
                          child: const Text(
                            'Effacer',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body:
          provider.translations.isEmpty
              ? const Center(
                child: Text('Aucune traduction dans l\'historique'),
              )
              : ListView.builder(
                itemCount: provider.translations.length,
                itemBuilder: (context, index) {
                  final translation = provider.translations[index];
                  return _buildTranslationCard(translation, provider);
                },
              ),
    );
  }

  Widget _buildTranslationCard(
    Translation translation,
    TranslationProvider provider,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.mediumPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: ListTile(
        title: Text(translation.original),
        subtitle: Text(translation.translated),
        trailing: IconButton(
          icon: Icon(
            translation.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: translation.isFavorite ? Colors.red : null,
          ),
          onPressed: () => provider.toggleFavorite(translation.id),
        ),
        onTap: () {
          provider.inputController.text = translation.original;
          provider.direction = translation.direction;
          provider.translate();
          //Navigator.pop(context); // Retour à l'écran principal
        },
      ),
    );
  }
}

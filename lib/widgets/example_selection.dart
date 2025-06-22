import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tradika/providers/translation_provider.dart';

class ExamplesSection extends StatelessWidget {
  const ExamplesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final examples = [
      {'text': 'Bonjour', 'translation': 'Mbɔk', 'direction': 'fr→bs'},
      {
        'text': 'Comment ça va?',
        'translation': 'Nâ mǒ bè tí̌?',
        'direction': 'fr→bs',
      },
      {
        'text': 'Merci beaucoup',
        'translation': 'Me yé nluk matôa',
        'direction': 'fr→bs',
      },
      {'text': 'Mbɔk', 'translation': 'Bonjour', 'direction': 'bs→fr'},
      {
        'text': 'Nâ mǒ bè tí̌',
        'translation': 'Comment allez-vous?',
        'direction': 'bs→fr',
      },
    ];

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 200),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Exemples à essayer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  examples.map((example) {
                    return ActionChip(
                      label: Text(example['text']!),
                      onPressed: () {
                        final provider = Provider.of<TranslationProvider>(
                          context,
                          listen: false,
                        );
                        provider.direction = example['direction']!;
                        provider.inputController.text = example['text']!;
                        provider.translate();
                      },
                      backgroundColor: Colors.grey[100],
                      labelStyle: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

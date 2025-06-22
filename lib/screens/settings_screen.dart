import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tradika/providers/app_settings_provider.dart';
import 'package:tradika/widgets/social_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../providers/translation_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettingsProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        children: [
          _buildSectionTitle('Apparence'),
          _buildThemeSelector(settings),
          const SizedBox(height: AppConstants.largePadding),

          _buildSectionTitle('Langue'),
          _buildLanguageSelector(settings),
          const SizedBox(height: AppConstants.largePadding),

          _buildSectionTitle('Historique'),
          _buildHistoryOption(context),
          const SizedBox(height: AppConstants.largePadding),

          _buildSectionTitle('Réseaux sociaux'),
          _buildSocialLinks(),
          const SizedBox(height: AppConstants.largePadding),

          _buildSectionTitle('À propos'),
          _buildAboutSection(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildThemeSelector(AppSettingsProvider settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        child: Column(
          children: [
            ListTile(
              title: const Text('Thème clair'),
              leading: const Icon(Icons.light_mode),
              trailing: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: settings.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    settings.setThemeMode(value);
                  }
                },
              ),
              onTap: () => settings.setThemeMode(ThemeMode.light),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Thème sombre'),
              leading: const Icon(Icons.dark_mode),
              trailing: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: settings.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    settings.setThemeMode(value);
                  }
                },
              ),
              onTap: () => settings.setThemeMode(ThemeMode.dark),
            ),
            const Divider(height: 1),
            ListTile(
              title: const Text('Système'),
              leading: const Icon(Icons.settings),
              trailing: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: settings.themeMode,
                onChanged: (value) {
                  if (value != null) {
                    settings.setThemeMode(value);
                  }
                },
              ),
              onTap: () => settings.setThemeMode(ThemeMode.system),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector(AppSettingsProvider settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.smallPadding),
        child: Column(
          children: [
            ListTile(
              title: const Text('Français'),
              leading: const Text('🇫🇷'),
              trailing: Radio<Locale>(
                value: const Locale('fr', 'FR'),
                groupValue: settings.locale,
                onChanged: (value) {
                  if (value != null) {
                    settings.setLocale(value);
                  }
                },
              ),
              onTap: () => settings.setLocale(const Locale('fr', 'FR')),
            ),
            // Ajouter d'autres langues si nécessaire
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryOption(BuildContext context) {
    return Card(
      child: ListTile(
        title: const Text('Effacer l\'historique'),
        leading: const Icon(Icons.delete),
        onTap: () {
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
                        Provider.of<TranslationProvider>(
                          context,
                          listen: false,
                        ).clearHistory();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Historique effacé')),
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
    );
  }

  Widget _buildSocialLinks() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SocialIcon(
                  icon: FontAwesomeIcons.globe,
                  label: 'JintẽliaS',
                  onTap: () => _openUrl(AppConstants.jinteliasUrl),
                ),
                SocialIcon(
                  icon: FontAwesomeIcons.linkedin,
                  label: 'LinkedIn',
                  onTap: () => _openUrl(AppConstants.linkedinUrl),
                ),
                SocialIcon(
                  icon: FontAwesomeIcons.x,
                  label: 'X',
                  onTap: () => _openUrl(AppConstants.twitterUrl),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SocialIcon(
                  icon: FontAwesomeIcons.youtube,
                  label: 'YouTube',
                  onTap: () => _openUrl(AppConstants.youtubeUrl),
                ),
                SocialIcon(
                  icon: FontAwesomeIcons.facebook,
                  label: 'Facebook',
                  onTap: () => _openUrl(AppConstants.facebookUrl),
                ),
                SocialIcon(
                  icon: FontAwesomeIcons.instagram,
                  label: 'Instagram',
                  onTap: () => _openUrl(AppConstants.instagramUrl),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.mediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tradika',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: AppConstants.smallPadding),
            const Text(
              'Traducteur Bassa ↔ Français',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            const Text(
              'Version beta 0.17.25',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: AppConstants.mediumPadding),
            const Text('© 2025 JintẽliaS. Tous droits réservés.'),
          ],
        ),
      ),
    );
  }
}

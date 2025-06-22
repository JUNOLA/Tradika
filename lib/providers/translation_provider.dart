import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tradika/api/api_service.dart';
import 'package:tradika/models/translation.dart';

class TranslationProvider with ChangeNotifier {
  String direction = 'fr→bs';
  String quality = 'fast';
  final TextEditingController inputController = TextEditingController();
  String outputText = 'La traduction apparaîtra ici';
  bool isLoading = false;
  String translationTime = '-';
  final TextEditingController correctionController = TextEditingController();
  bool showCorrectionSection = false;
  bool apiConnected = true;
  StreamController<bool> connectionStream = StreamController<bool>.broadcast();
  Timer? _connectionTimer;
  List<Translation> translations = [];
  List<Translation> favorites = [];

  TranslationProvider() {
    inputController.text = 'Bonjour, je suis Tradika';
    _loadTranslations();
    _checkConnectionPeriodically();
  }

  void _checkConnectionPeriodically() {
    _connectionTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final previousState = apiConnected;
      try {
        // Vérifier la connexion avec une requête simple
        await ApiService.checkConnection();
        apiConnected = true;
      } catch (e) {
        apiConnected = false;
      }

      if (apiConnected != previousState) {
        notifyListeners();
        connectionStream.add(apiConnected);
      }
    });
  }

  void switchDirection() {
    // Échanger le texte entre les champs d'entrée et de sortie
    final temp = inputController.text;
    inputController.text = outputText;
    outputText = temp;

    // Inverser la direction
    direction = direction == 'fr→bs' ? 'bs→fr' : 'fr→bs';

    notifyListeners();
  }

  void setQuality(String newQuality) {
    quality = newQuality;
    notifyListeners();
  }

  Future<void> translate() async {
    if (inputController.text.isEmpty) {
      outputText = 'Veuillez entrer du texte à traduire.';
      notifyListeners();
      return;
    }

    isLoading = true;
    showCorrectionSection = false;
    notifyListeners();

    final startTime = DateTime.now();

    try {
      final translation = await ApiService.translate(
        text: inputController.text,
        direction: direction,
        quality: quality,
      );

      outputText = translation;
      showCorrectionSection = true;
      correctionController.text = outputText;
      apiConnected = true;

      // Sauvegarder la traduction
      final newTranslation = Translation(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        original: inputController.text,
        translated: outputText,
        direction: direction,
        timestamp: DateTime.now(),
      );

      translations.insert(0, newTranslation);
      await _saveTranslations();
    } catch (e) {
      outputText = 'Échec de connexion à l\'API';
      apiConnected = false;
    } finally {
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      translationTime = '${duration.inSeconds}s';
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitCorrection(BuildContext context) async {
    if (correctionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une correction valide'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final success = await ApiService.submitCorrection(
        original: inputController.text,
        translation: outputText,
        correction: correctionController.text,
        direction: direction,
      );

      if (success) {
        outputText = correctionController.text;

        // Mettre à jour la dernière traduction
        if (translations.isNotEmpty) {
          translations[0] = translations[0].copyWith(translated: outputText);
          await _saveTranslations();
        }

        notifyListeners();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correction soumise avec succès!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Échec de soumission de la correction'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors de la soumission de la correction'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> toggleFavorite(String id) async {
    final index = translations.indexWhere((t) => t.id == id);
    if (index != -1) {
      translations[index] = translations[index].copyWith(
        isFavorite: !translations[index].isFavorite,
      );

      if (translations[index].isFavorite) {
        favorites.add(translations[index]);
      } else {
        favorites.removeWhere((t) => t.id == id);
      }

      await _saveTranslations();
      notifyListeners();
    }
  }

  Future<void> _saveTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final translationsJson = translations.map((t) => t.toMap()).toList();
    await prefs.setString('translations', translationsJson.toString());

    final favoritesJson = favorites.map((t) => t.toMap()).toList();
    await prefs.setString('favorites', favoritesJson.toString());
  }

  Future<void> _loadTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final translationsJson = prefs.getString('translations');
    final favoritesJson = prefs.getString('favorites');

    if (translationsJson != null) {
      final List<dynamic> decoded = translationsJson as List;
      translations = decoded.map((json) => Translation.fromMap(json)).toList();
    }

    if (favoritesJson != null) {
      final List<dynamic> decoded = favoritesJson as List;
      favorites = decoded.map((json) => Translation.fromMap(json)).toList();
    }

    notifyListeners();
  }

  Future<void> clearHistory() async {
    translations.clear();
    await _saveTranslations();
    notifyListeners();
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    connectionStream.close();
    super.dispose();
  }
}
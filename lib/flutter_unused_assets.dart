import 'dart:developer';

import 'package:flutter_unused_assets/asset_analyzer.dart';

Future<void> analyzeProjectAssets() async {
  final analyzer = AssetAnalyzer();

  try {
    // print('Analyse du dossier lib en cours...');
    final assets = await analyzer.findAssetsInLibFolder();
    // print('\nAssets trouvés :');
    if (assets.isEmpty) {
      // print('Aucun asset trouvé dans le code.');
    } else {
      for (final asset in assets) {
        log('- $asset');
      }
    }
    // Vérifier l'existence des fichiers
    log('\nVérification de l\'existence des fichiers...');
    final existence = await analyzer.verifyAssetsExistence(assets);

    // print('\nRésultats de la vérification :');
    existence.forEach((asset, exists) {
      final status = exists ? '✓' : '✗';
      log('$status $asset');
    });
  } catch (e) {
    log('Erreur lors de l\'analyse : $e');
  }
}

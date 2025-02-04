// ignore_for_file: avoid_print

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';

class AssetAnalyzer {
  /// Analyze the pubspec file and get the list of assets folders from it
  Future<Map<String, List<String>>> analyzePubspecFileAndGetAssets() async {
    final pubspecFile = File('pubspec.yaml');
    final content = await pubspecFile.readAsString();
    final pubspec = Pubspec.parse(content);

    final result = <String, List<String>>{
      'folders': <String>[],
      'files': <String>[],
    };

    for (final asset in pubspec.flutter?['assets'] ?? []) {
      if (asset.endsWith('/')) {
        result['folders']!.add(path.normalize(asset));
      } else if (asset.contains('*')) {
        final dirPath = asset.split('*').first;
        final normalized = _normalizeFolderPath(dirPath);
        if (!result['folders']!.contains(normalized)) {
          result['folders']!.add(normalized);
        }
      } else {
        result['files']!.add(path.normalize(asset));
      }
    }

    result['folders'] = result['folders']!.toSet().toList();
    result['files'] = result['files']!.toSet().toList();

    return result;
  }

  /// Analyze the project and get all files
  Future<List<String>> analyzeProjectAndGetFiles() async {
    final assets = await analyzePubspecFileAndGetAssets();
    final allFiles = <String>[...assets['files']!];

    for (final folder in assets['folders']!) {
      final directory = Directory(folder);
      if (await directory.exists()) {
        await for (final entity in directory.list(recursive: true)) {
          if (entity is File) {
            final relativePath = path.relative(
              entity.path,
              from: Directory.current.path,
            );
            allFiles.add(path.normalize(relativePath));
          }
        }
      }
    }

    return allFiles.toSet().toList()..sort();
  }

  String _normalizeFolderPath(String rawPath) {
    var cleanedPath = rawPath.replaceAll('\\', '/');
    return path
        .normalize(cleanedPath.endsWith('/') ? cleanedPath : '$cleanedPath/');
  }

  /// Analyze recursively the lib folder and return the list of used assets
  Future<List<String>> findAssetsInLibFolder() async {
    final assetPaths = <String>{};
    final libDir = Directory('lib');

    if (!await libDir.exists()) {
      throw Exception('Le dossier lib n\'existe pas');
    }
    await for (final entity in libDir.list(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        assetPaths.addAll(await _analyzeFile(entity));
      }
    }

    return assetPaths.toList()..sort();
  }

  /// Analyze a Dart file to find used assets
  Future<Set<String>> _analyzeFile(File file) async {
    final content = await file.readAsString();
    final assets = <String>{};

    final patterns = [
      RegExp(r'''Image\.asset\([^)]*?(['"])(.*?)\1''',
          dotAll: true, caseSensitive: false),
      RegExp(r'''AssetImage\([^)]*?(['"])(.*?)\1''',
          dotAll: true, caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final matches = pattern.allMatches(content);
      for (final match in matches) {
        if (match.groupCount >= 1) {
          final assetPath = match.group(2)!;
          assets.add(_normalizePath(assetPath));
        }
      }
    }

    return assets;
  }

  /// Normalize an asset path
  String _normalizePath(String assetPath) {
    var normalized = assetPath.replaceAll(r'\', '/');
    normalized = normalized.replaceAll(RegExp(r'\$\w+|(\${[^}]+})'), '');
    return path.normalize(normalized);
  }

  /// Verify if the found assets actually exist
  Future<Map<String, bool>> verifyAssetsExistence(
      List<String> assetPaths) async {
    final results = <String, bool>{};

    for (final assetPath in assetPaths) {
      results[assetPath] = await File(assetPath).exists();
    }

    return results;
  }

  /// Analyse Repport
  Future<void> analyzeProjectAssets() async {
    try {
      print("🔍 Début de l'analyse des assets...\n");
      // Récupérer toutes les données nécessaires
      final declaredAssets = await analyzeProjectAndGetFiles();
      final usedAssets = await findAssetsInLibFolder();
      final existingDeclaredAssets =
          await verifyAssetsExistence(declaredAssets);

      // Calculer les assets non utilisés
      final unusedAssets = declaredAssets
          .where((asset) =>
              !usedAssets.contains(asset) &&
              existingDeclaredAssets[asset] == true)
          .toList();

      // Calculer la taille totale des assets non utilisés
      double totalUnusedSizeMB = 0;
      final assetSizes = <String, double>{};

      for (final asset in unusedAssets) {
        try {
          final file = File(asset);
          final sizeBytes = await file.length();
          final sizeMB = sizeBytes / (1024 * 1024);
          assetSizes[asset] = sizeMB;
          totalUnusedSizeMB += sizeMB;
        } catch (e) {
          assetSizes[asset] = 0.0;
        }
      }

      // Afficher les résultats
      _printColored(
          'ASSETS UTILISÉS (${usedAssets.length}):', ConsoleColor.green);
      for (final asset in usedAssets) {
        print('  $_greenCheck ${asset.padRight(60)}');
      }

      _printColored(
          '\nASSETS NON UTILISÉS (${unusedAssets.length}):', ConsoleColor.red);
      for (final asset in unusedAssets) {
        final size = assetSizes[asset]?.toStringAsFixed(2) ?? '0.00';
        print('  $_redCross ${asset.padRight(55)} $size MB');
      }

      _printColored(
          '\nTOTAL ESPACE PERDU: ${totalUnusedSizeMB.toStringAsFixed(2)} MB',
          ConsoleColor.yellow,
          isBold: true);
    } catch (e) {
      print('\n❌ Erreur lors de l\'analyse : ${e.toString()}');
    }
  }
}

// Helper functions and constants
const _greenCheck = '\u001b[32m✓\u001b[0m';
const _redCross = '\u001b[31m✗\u001b[0m';

enum ConsoleColor {
  black(30),
  red(31),
  green(32),
  yellow(33),
  blue(34),
  magenta(35),
  cyan(36),
  white(37);

  final int code;
  const ConsoleColor(this.code);
}

void _printColored(String text, ConsoleColor color, {bool isBold = false}) {
  final style = isBold ? '1;' : '';
  print('\u001b[${style}${color.code}m$text\u001b[0m');
}

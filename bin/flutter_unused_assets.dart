#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'package:flutter_unused_assets/flutter_unused_assets.dart';

void main(List<String> arguments) async {
  printColored("\n\n🔍 Démarrage de l'exécution...\n\n", ConsoleColor.blue);

  final parser = ArgParser()
    ..addFlag('help', abbr: 'h')
    ..addOption('output', abbr: 'o', defaultsTo: 'unused_assets.json');
  final args = parser.parse(arguments);

  if (args['help'] == true) {
    print('Usage: flutter_unused_assets [--output=filename.json]\n');
    exit(0);
  }

  try {
    final analyzer = AssetAnalyzer();
    await analyzer.analyzeProjectAssets();
  } catch (e) {
    printColored("\n\nune erruer est survenue :$e\n\n", ConsoleColor.red);
    stderr.writeln('Error: $e');
    exit(1);
  }
}

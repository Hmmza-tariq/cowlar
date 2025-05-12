import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';

import 'flavors.dart';

const String appFlavor =
    String.fromEnvironment('FLAVOR', defaultValue: 'cowlar_dev');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  try {
    final flavorName = appFlavor;
    F.appFlavor = Flavor.values.firstWhere(
      (element) => element.name == flavorName,
      orElse: () => Flavor.cowlar_dev,
    );
  } catch (e) {
    F.appFlavor = Flavor.cowlar_dev;
  }

  runApp(const App());
}

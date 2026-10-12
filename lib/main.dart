import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/di/injection_container.dart' as di;
import 'core/localization/locale_controller.dart';
import 'core/theme/theme_controller.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = await SharedPreferences.getInstance();
  await di.init(prefs: prefs);
  final localeController = LocaleController(prefs);
  localeController.hydrate();
  final themeController = ThemeController(prefs);
  themeController.hydrate();
  runApp(
    DriverApp(
      localeController: localeController,
      themeController: themeController,
    ),
  );
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection_container.dart';

Future<void> main() async {
  // Required before any async work prior to runApp.
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint(
      '⚠️ Firebase init failed — check your native Firebase config. ($e)',
    );
  }

  // Register all dependencies in the service locator.
  await initDependencies();

  runApp(const AliveApp());
}

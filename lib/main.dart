
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'screens/auth_gate.dart';
import 'theme/cee_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const CeeApp());
}

class CeeApp extends StatelessWidget {
  const CeeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CEE',
      debugShowCheckedModeBanner: false,
      theme: CeeTheme.dark,
      home: const AuthGate(),
    );
  }
}

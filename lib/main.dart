import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onecitizen/app.dart';
import 'package:onecitizen/firebase_options.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/services/auth_service.dart';
import 'package:onecitizen/services/seed_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await seedCardTypes();

  final authProvider = AuthProvider(authService: AuthService());
  await authProvider.checkSession();

  runApp(OneCitizenApp(authProvider: authProvider));
}

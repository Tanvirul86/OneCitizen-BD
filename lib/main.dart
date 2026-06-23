import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:onecitizen/app.dart';
import 'package:onecitizen/firebase_options.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/services/api_client.dart';
import 'package:onecitizen/services/auth_service.dart';
import 'package:onecitizen/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  final storageService = StorageService();
  final apiClient = ApiClient(storageService: storageService);
  final authService = AuthService(
    apiClient: apiClient,
    storageService: storageService,
  );
  final authProvider = AuthProvider(
    authService: authService,
    storageService: storageService,
  );

  await authProvider.checkSession();

  runApp(OneCitizenApp(authProvider: authProvider));
}

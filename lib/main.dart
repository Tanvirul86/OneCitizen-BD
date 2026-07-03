import 'package:flutter/material.dart';
import 'package:onecitizen/app.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/services/api_client.dart';
import 'package:onecitizen/services/auth_service.dart';
import 'package:onecitizen/services/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final apiClient = ApiClient(storageService: storageService);
  final authService = AuthService(
    apiClient: apiClient,
    storageService: storageService,
  );
  final authProvider = AuthProvider(authService: authService);

  await authProvider.checkSession();

  runApp(OneCitizenApp(authProvider: authProvider));
}

import 'package:firebase_core/firebase_core.dart';

/// Firebase configuration placeholder.
/// Run `flutterfire configure` to generate firebase_options.dart
/// and replace this file with the generated one.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'YOUR_API_KEY',
      appId: 'YOUR_APP_ID',
      messagingSenderId: 'YOUR_SENDER_ID',
      projectId: 'onecitizen-bd',
    );
  }
}

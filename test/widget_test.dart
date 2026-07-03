import 'package:flutter_test/flutter_test.dart';
import 'package:onecitizen/app.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/services/api_client.dart';
import 'package:onecitizen/services/auth_service.dart';
import 'package:onecitizen/services/storage_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final storageService = StorageService();
    final apiClient = ApiClient(storageService: storageService);
    final authProvider = AuthProvider(
      authService: AuthService(
        apiClient: apiClient,
        storageService: storageService,
      ),
    );

    await tester.pumpWidget(OneCitizenApp(authProvider: authProvider));
    await tester.pump();

    expect(find.text('OneCitizen BD'), findsWidgets);
  });
}

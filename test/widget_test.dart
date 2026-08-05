import 'package:flutter_test/flutter_test.dart';
import 'package:onecitizen/app.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/services/auth_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final authProvider = AuthProvider(authService: AuthService());

    await tester.pumpWidget(OneCitizenApp(authProvider: authProvider));
    await tester.pump();

    expect(find.text('OneCitizen BD'), findsWidgets);
  });
}

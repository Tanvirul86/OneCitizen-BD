import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:onecitizen/app.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/services/api_client.dart';
import 'package:onecitizen/services/auth_service.dart';
import 'package:onecitizen/services/storage_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }

  Future<void> openDrawerAndTap(WidgetTester tester, String label) async {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    final finder = find.descendant(of: find.byType(Drawer), matching: find.text(label));
    await tester.tap(finder);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }

  testWidgets('full citizen + admin walkthrough', (tester) async {
    final storageService = StorageService();
    final apiClient = ApiClient(storageService: storageService);
    final authService = AuthService(apiClient: apiClient, storageService: storageService);
    final authProvider = AuthProvider(authService: authService);
    await authProvider.checkSession();

    await tester.pumpWidget(OneCitizenApp(authProvider: authProvider));
    // Splash screen waits 2s before redirecting.
    await tester.pump(const Duration(seconds: 3));
    await settle(tester);

    debugPrint('--- STEP: public home ---');
    expect(find.text('A Unified Welfare Card\nManagement Platform'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Create an Account'), findsOneWidget);

    debugPrint('--- STEP: about page ---');
    await tester.tap(find.text('About'));
    await settle(tester);
    expect(find.text('About OneCitizen BD'), findsOneWidget);
    await tester.tap(find.byType(BackButton).first);
    await settle(tester);

    debugPrint('--- STEP: register ---');
    await tester.tap(find.widgetWithText(OutlinedButton, 'Create an Account'));
    await settle(tester);
    expect(find.text('Create Account'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'NID Number'), '1234567890');
    await tester.enterText(find.widgetWithText(TextFormField, 'First Name'), 'Test');
    await tester.enterText(find.widgetWithText(TextFormField, 'Last Name'), 'Citizen');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test.citizen@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Phone Number'), '01700000000');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Register'));
    await settle(tester);

    debugPrint('--- STEP: profile completion ---');
    expect(find.text('Complete Your Profile'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await settle(tester);

    debugPrint('--- STEP: citizen dashboard ---');
    expect(find.text('OneCitizen BD'), findsOneWidget);
    expect(find.text('Check Eligibility'), findsOneWidget);
    expect(find.text('Apply for Card'), findsOneWidget);
    expect(find.text('Upload Documents'), findsOneWidget);
    expect(find.text('Distribution History'), findsOneWidget);

    debugPrint('--- STEP: eligibility ---');
    await tester.tap(find.text('Check Eligibility'));
    await settle(tester);
    expect(find.text('Farmer Card'), findsWidgets);
    expect(find.text('Family Card'), findsWidgets);
    expect(find.text('Education Card'), findsWidgets);
    await tester.tap(find.byType(BackButton).first);
    await settle(tester);

    debugPrint('--- STEP: documents ---');
    await tester.tap(find.text('Upload Documents'));
    await settle(tester);
    expect(find.text('Document Upload'), findsOneWidget);
    await tester.tap(find.byType(BackButton).first);
    await settle(tester);

    debugPrint('--- STEP: apply for card ---');
    await tester.tap(find.text('Apply for Card'));
    await settle(tester);
    expect(find.text('Apply for a Card'), findsOneWidget);
    await tester.tap(find.byType(DropdownButtonFormField<String>));
    await settle(tester);
    await tester.tap(find.text('Farmer Card').last);
    await settle(tester);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit Application'));
    await settle(tester);

    debugPrint('--- STEP: my applications ---');
    expect(find.text('My Applications'), findsWidgets);
    await tester.tap(find.byType(ListTile).first);
    await settle(tester);
    expect(find.text('Application Details'), findsOneWidget);
    await tester.tap(find.byType(BackButton).first);
    await settle(tester);

    debugPrint('--- STEP: distribution history (bottom nav) ---');
    await tester.tap(find.text('Funds'));
    await settle(tester);
    expect(find.text('Distribution History'), findsWidgets);

    debugPrint('--- STEP: notifications (bottom nav) ---');
    await tester.tap(find.text('Notifications'));
    await settle(tester);
    expect(find.text('Notifications'), findsWidgets);

    debugPrint('--- STEP: profile + logout ---');
    await tester.tap(find.text('Profile'));
    await settle(tester);
    expect(find.text('My Profile'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.logout));
    await settle(tester);

    debugPrint('--- STEP: admin login ---');
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.tap(find.text('Admin'));
    await settle(tester);
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'admin@onecitizen.bd');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
    await settle(tester);

    debugPrint('--- STEP: admin dashboard ---');
    expect(find.text('OneCitizen Admin'), findsOneWidget);
    expect(find.text('Total Applications'), findsOneWidget);

    debugPrint('--- STEP: new applications ---');
    await openDrawerAndTap(tester, 'New Applications');
    expect(find.text('Applications'), findsWidgets);
    await tester.tap(find.byType(ListTile).first);
    await settle(tester);

    debugPrint('--- STEP: application review + approve ---');
    expect(find.text('Application Review'), findsOneWidget);
    final approveButton = find.widgetWithText(ElevatedButton, 'Approve');
    if (approveButton.evaluate().isNotEmpty) {
      await tester.tap(approveButton);
      await settle(tester);
    }
    await tester.tap(find.byType(BackButton).first);
    await settle(tester);

    debugPrint('--- STEP: document validation ---');
    await openDrawerAndTap(tester, 'Document Validation');
    expect(find.text('Document Validation'), findsWidgets);
    final validButton = find.widgetWithText(ElevatedButton, 'Valid');
    if (validButton.evaluate().isNotEmpty) {
      await tester.tap(validButton.first);
      await settle(tester);
    }

    debugPrint('--- STEP: approved cards ---');
    await openDrawerAndTap(tester, 'Approved Cards');
    expect(find.text('Approved Cards'), findsWidgets);

    debugPrint('--- STEP: fund distribution ---');
    await openDrawerAndTap(tester, 'Fund Distribution');
    expect(find.text('Fund Distribution'), findsWidgets);

    debugPrint('--- STEP: distribution records ---');
    await openDrawerAndTap(tester, 'Distribution Records');
    expect(find.text('Distribution Records'), findsWidgets);

    debugPrint('--- STEP: citizen accounts ---');
    await openDrawerAndTap(tester, 'Citizen Accounts');
    expect(find.text('Citizen Accounts'), findsWidgets);

    debugPrint('--- STEP: analytics ---');
    await openDrawerAndTap(tester, 'Analytics');
    expect(find.text('Admin Analytics'), findsOneWidget);

    debugPrint('--- WALKTHROUGH COMPLETE ---');
  });
}

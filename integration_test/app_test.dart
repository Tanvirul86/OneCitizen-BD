import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:onecitizen/app.dart';
import 'package:onecitizen/firebase_options.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/services/auth_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  });

  Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }

  Future<void> completeProfileIfShown(WidgetTester tester) async {
    // The router redirects to the full profile-completion form whenever the
    // profile is incomplete (missing date of birth / occupation / address) —
    // sometimes right after login, sometimes only when navigating into a
    // gated screen like apply-for-card. "Skip" only dismisses this screen
    // without completing the profile, so the redirect just fires again on
    // the next gated navigation — fill and submit it for real instead.
    if (find.text('Save & Continue').evaluate().isEmpty) return;

    await tester.tap(find.text('Select date'));
    await settle(tester);
    await tester.tap(find.text('OK'));
    await settle(tester);

    await tester.tap(find.text('Gender'));
    await settle(tester);
    await tester.tap(find.text('Male').last);
    await settle(tester);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Address'),
      '123 Main Road, Dhaka',
    );

    await tester.tap(find.text('Occupation'));
    await settle(tester);
    await tester.tap(find.text('Farmer').last);
    await settle(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Save & Continue'));
    await settle(tester);
  }

  Future<void> openDrawerAndTap(WidgetTester tester, String label) async {
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
    final finder = find.descendant(
      of: find.byType(Drawer),
      matching: find.text(label),
    );
    await tester.tap(finder);
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }

  testWidgets('full citizen + admin walkthrough', (tester) async {
    // Unique per run so repeated test runs don't collide on
    // "email-already-in-use" against the live Firebase project.
    final runId = DateTime.now().millisecondsSinceEpoch;
    final citizenEmail = 'test.citizen.$runId@example.com';

    final authProvider = AuthProvider(authService: AuthService());
    await authProvider.checkSession();

    await tester.pumpWidget(OneCitizenApp(authProvider: authProvider));
    // Splash screen waits 2s before redirecting.
    await tester.pump(const Duration(seconds: 3));
    await settle(tester);

    debugPrint('--- STEP: public home ---');
    expect(find.text('Your welfare, simplified.'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Create Account'), findsWidgets);
    expect(find.widgetWithText(OutlinedButton, 'Sign In'), findsWidgets);

    debugPrint('--- STEP: about page ---');
    await tester.tap(find.text('About'));
    await settle(tester);
    expect(find.text('About'), findsWidgets);
    await tester.tap(find.byType(BackButton).first);
    await settle(tester);

    debugPrint('--- STEP: register ---');
    await tester.tap(find.widgetWithText(FilledButton, 'Create Account').first);
    await settle(tester);
    expect(find.text('Create your account'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'First Name'),
      'Test',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Last Name'),
      'Citizen',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email address'),
      citizenEmail,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Phone Number'),
      '01700000000',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'admin123',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await settle(tester);

    debugPrint('--- STEP: citizen login (post-registration) ---');
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email address'),
      citizenEmail,
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'admin123',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await settle(tester);
    await completeProfileIfShown(tester);

    debugPrint('--- STEP: citizen dashboard ---');
    expect(find.text('OneCitizen BD'), findsOneWidget);
    expect(find.text('Apply for Card'), findsWidgets);
    expect(find.text('Check Eligibility'), findsNothing);
    expect(find.text('Upload Docs'), findsNothing);

    debugPrint('--- STEP: apply for card ---');
    await tester.tap(find.text('Apply for Card').first);
    await settle(tester);
    await completeProfileIfShown(tester);
    if (find.text('Select Card').evaluate().isEmpty) {
      // The profile-completion redirect intercepted this navigation instead
      // of the earlier one — try again now that it's been skipped.
      await tester.tap(find.text('Apply for Card').first);
      await settle(tester);
    }
    expect(find.text('Apply for Card'), findsWidgets);
    expect(find.text('Select Card'), findsOneWidget);
    await tester.tap(find.text('Farmer Card').first);
    await settle(tester);
    expect(find.text('Farmer Card requirements'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Proceed'));
    await settle(tester);
    expect(find.text('Farmer Card application form'), findsOneWidget);
    expect(find.text('Required documents'), findsOneWidget);
    expect(find.text('Preview Application'), findsOneWidget);
    await tester.tap(find.byType(BackButton).first);
    await settle(tester);
    await tester.tap(find.text('Applications'));
    await settle(tester);

    debugPrint('--- STEP: my applications ---');
    expect(find.text('My Applications'), findsWidgets);
    // The apply-for-card flow above was only previewed, not submitted, so
    // this fresh test citizen legitimately has no applications yet.
    expect(find.text('No applications submitted yet.'), findsOneWidget);

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
    expect(find.text('Edit Profile'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.logout_rounded));
    await settle(tester);

    debugPrint('--- STEP: admin login ---');
    expect(find.text('Welcome back'), findsOneWidget);
    await tester.tap(find.text('Admin'));
    await settle(tester);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Email address'),
      'admin@gmail.com',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'admin123',
    );
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
    await settle(tester);

    debugPrint('--- STEP: admin dashboard ---');
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Total Applications'), findsWidgets);

    debugPrint('--- STEP: new applications ---');
    await openDrawerAndTap(tester, 'New Applications');
    expect(find.text('New Applications'), findsWidgets);
    await tester.tap(find.byType(Card).first);
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
    expect(find.text('Analytics'), findsWidgets);

    debugPrint('--- WALKTHROUGH COMPLETE ---');
  });
}

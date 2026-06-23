import 'package:go_router/go_router.dart';
import 'package:onecitizen/models/complaint.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/screens/admin/admin_screens.dart';
import 'package:onecitizen/screens/auth/otp_verification_screen.dart';
import 'package:onecitizen/screens/auth/phone_login_screen.dart';
import 'package:onecitizen/screens/auth/profile_setup_screen.dart';
import 'package:onecitizen/screens/citizen/apply_card_screen.dart';
import 'package:onecitizen/screens/citizen/application_tracker_screen.dart';
import 'package:onecitizen/screens/citizen/citizen_shell.dart';
import 'package:onecitizen/screens/citizen/complaints_screen.dart';
import 'package:onecitizen/screens/citizen/digital_identity_screen.dart';
import 'package:onecitizen/screens/citizen/eligibility_screen.dart';
import 'package:onecitizen/screens/citizen/home_screen.dart';
import 'package:onecitizen/screens/citizen/my_cards_screen.dart';
import 'package:onecitizen/screens/citizen/profile_screen.dart';
import 'package:onecitizen/screens/officer/officer_application_detail_screen.dart';
import 'package:onecitizen/screens/officer/officer_dashboard_screen.dart';
import 'package:onecitizen/screens/officer/officer_profile_screen.dart';
import 'package:onecitizen/screens/officer/officer_shell.dart';
import 'package:onecitizen/screens/splash_screen.dart';

class AppRouter {
  static GoRouter create(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.status == AuthStatus.authenticated;
        final location = state.matchedLocation;
        final isAuthRoute =
            location == '/login' || location == '/otp' || location == '/';
        final isProfileSetup = location == '/profile-setup';

        if (authProvider.status == AuthStatus.initial) return null;
        if (!isLoggedIn && !isAuthRoute && !isProfileSetup) return '/login';
        if (isLoggedIn && isAuthRoute) {
          return homeForRole(authProvider.user?.role ?? UserRole.citizen);
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/login', builder: (context, state) => const PhoneLoginScreen()),
        GoRoute(path: '/otp', builder: (context, state) => const OtpVerificationScreen()),
        GoRoute(path: '/profile-setup', builder: (context, state) => const ProfileSetupScreen()),

        // ── Citizen shell ────────────────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => CitizenShell(child: child),
          routes: [
            GoRoute(path: '/citizen', builder: (context, state) => const CitizenHomeScreen()),
            GoRoute(path: '/citizen/cards', builder: (context, state) => const MyCardsScreen()),
            GoRoute(
              path: '/citizen/cards/:id',
              builder: (context, state) => CardDetailScreen(cardId: state.pathParameters['id']!),
            ),
            GoRoute(path: '/citizen/tracker', builder: (context, state) => const ApplicationTrackerScreen()),
            GoRoute(path: '/citizen/profile', builder: (context, state) => const ProfileScreen()),
          ],
        ),

        // Citizen standalone routes (outside shell so back button works)
        GoRoute(
          path: '/citizen/apply',
          builder: (context, state) => ApplyCardScreen(initialCardTypeId: state.extra as String?),
        ),
        GoRoute(
          path: '/citizen/tracker/:id',
          builder: (context, state) => ApplicationDetailScreen(applicationId: state.pathParameters['id']!),
        ),
        GoRoute(path: '/citizen/eligibility', builder: (context, state) => const EligibilityScreen()),
        GoRoute(path: '/citizen/identity', builder: (context, state) => const DigitalIdentityScreen()),
        GoRoute(path: '/citizen/complaints', builder: (context, state) => const ComplaintsScreen()),
        GoRoute(path: '/citizen/complaints/new', builder: (context, state) => const ComplaintFormScreen()),
        GoRoute(
          path: '/citizen/complaints/:id',
          builder: (context, state) => ComplaintDetailScreen(complaint: state.extra! as Complaint),
        ),

        // ── Officer shell ────────────────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => OfficerShell(child: child),
          routes: [
            GoRoute(path: '/officer', builder: (context, state) => const OfficerDashboardScreen()),
            GoRoute(path: '/officer/profile', builder: (context, state) => const OfficerProfileScreen()),
          ],
        ),
        // Officer detail outside shell so it gets its own back button
        GoRoute(
          path: '/officer/applications/:id',
          builder: (context, state) => OfficerApplicationDetailScreen(
            applicationId: state.pathParameters['id']!,
          ),
        ),

        // ── Admin shell ──────────────────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
            GoRoute(path: '/admin/users', builder: (context, state) => const UserManagementScreen()),
            GoRoute(path: '/admin/card-types', builder: (context, state) => const CardTypeManagementScreen()),
            GoRoute(path: '/admin/officers', builder: (context, state) => const OfficerManagementScreen()),
            GoRoute(path: '/admin/complaints', builder: (context, state) => const ComplaintOversightScreen()),
            GoRoute(path: '/admin/logs', builder: (context, state) => const SystemLogsScreen()),
          ],
        ),
      ],
    );
  }

  static String homeForRole(UserRole role) {
    switch (role) {
      case UserRole.officer:
        return '/officer';
      case UserRole.admin:
        return '/admin';
      case UserRole.citizen:
        return '/citizen';
    }
  }
}

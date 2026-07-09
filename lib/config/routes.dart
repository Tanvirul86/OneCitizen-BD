import 'package:go_router/go_router.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/screens/admin/admin_analytics_screen.dart';
import 'package:onecitizen/screens/admin/admin_dashboard_screen.dart';
import 'package:onecitizen/screens/admin/admin_shell.dart';
import 'package:onecitizen/screens/admin/application_review_screen.dart';
import 'package:onecitizen/screens/admin/approved_cards_screen.dart';
import 'package:onecitizen/screens/admin/citizen_accounts_screen.dart';
import 'package:onecitizen/screens/admin/distribution_records_screen.dart';
import 'package:onecitizen/screens/admin/document_validation_screen.dart';
import 'package:onecitizen/screens/admin/fund_distribution_screen.dart';
import 'package:onecitizen/screens/admin/new_applications_screen.dart';
import 'package:onecitizen/screens/citizen/apply_card_screen.dart';
import 'package:onecitizen/screens/citizen/citizen_shell.dart';
import 'package:onecitizen/screens/citizen/dashboard_screen.dart';
import 'package:onecitizen/screens/citizen/distribution_history_screen.dart';
import 'package:onecitizen/screens/citizen/document_upload_screen.dart';
import 'package:onecitizen/screens/citizen/eligibility_screen.dart';
import 'package:onecitizen/screens/citizen/my_applications_screen.dart';
import 'package:onecitizen/screens/citizen/notifications_screen.dart';
import 'package:onecitizen/screens/citizen/profile_completion_screen.dart';
import 'package:onecitizen/screens/citizen/profile_screen.dart';
import 'package:onecitizen/screens/public/about_screen.dart';
import 'package:onecitizen/screens/public/home_screen.dart';
import 'package:onecitizen/screens/public/login_screen.dart';
import 'package:onecitizen/screens/public/register_screen.dart';
import 'package:onecitizen/screens/splash_screen.dart';

class AppRouter {
  static GoRouter create(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.status == AuthStatus.authenticated;
        final location = state.matchedLocation;
        final isPublicRoute = location == '/' ||
            location == '/home' ||
            location == '/login' ||
            location == '/register' ||
            location == '/about';

        if (authProvider.status == AuthStatus.initial) return null;
        if (!isLoggedIn && !isPublicRoute) return '/login';
        if (isLoggedIn && (location == '/login' || location == '/register')) {
          return homeForRole(authProvider.user?.role ?? UserRole.citizen);
        }
        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
        GoRoute(path: '/home', builder: (context, state) => const PublicHomeScreen()),
        GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
        GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
        GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),

        // ── Citizen shell ────────────────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => CitizenShell(child: child),
          routes: [
            GoRoute(path: '/citizen', builder: (context, state) => const CitizenDashboardScreen()),
            GoRoute(path: '/citizen/applications', builder: (context, state) => const MyApplicationsScreen()),
            GoRoute(path: '/citizen/distributions', builder: (context, state) => const DistributionHistoryScreen()),
            GoRoute(path: '/citizen/notifications', builder: (context, state) => const NotificationsScreen()),
            GoRoute(path: '/citizen/profile', builder: (context, state) => const ProfileScreen()),
          ],
        ),

        // Citizen standalone routes (outside shell so back button works)
        GoRoute(path: '/citizen/profile-completion', builder: (context, state) => const ProfileCompletionScreen()),
        GoRoute(path: '/citizen/documents', builder: (context, state) => const DocumentUploadScreen()),
        GoRoute(path: '/citizen/eligibility', builder: (context, state) => const EligibilityScreen()),
        GoRoute(
          path: '/citizen/apply',
          builder: (context, state) => ApplyCardScreen(initialCardTypeId: state.extra as String?),
        ),
        GoRoute(
          path: '/citizen/applications/:id',
          builder: (context, state) => ApplicationDetailScreen(applicationId: state.pathParameters['id']!),
        ),

        // ── Admin shell ──────────────────────────────────────────────────
        ShellRoute(
          builder: (context, state, child) => AdminShell(child: child),
          routes: [
            GoRoute(path: '/admin', builder: (context, state) => const AdminDashboardScreen()),
            GoRoute(
              path: '/admin/applications',
              builder: (context, state) => NewApplicationsScreen(initialCardTypeName: state.extra as String?),
            ),
            GoRoute(path: '/admin/documents', builder: (context, state) => const DocumentValidationScreen()),
            GoRoute(path: '/admin/approved-cards', builder: (context, state) => const ApprovedCardsScreen()),
            GoRoute(path: '/admin/distributions/new', builder: (context, state) => const FundDistributionScreen()),
            GoRoute(path: '/admin/distributions', builder: (context, state) => const DistributionRecordsScreen()),
            GoRoute(path: '/admin/citizens', builder: (context, state) => const CitizenAccountsScreen()),
            GoRoute(path: '/admin/analytics', builder: (context, state) => const AdminAnalyticsScreen()),
          ],
        ),
        // Admin detail outside shell so it gets its own back button
        GoRoute(
          path: '/admin/applications/:id',
          builder: (context, state) => ApplicationReviewScreen(applicationId: state.pathParameters['id']!),
        ),
      ],
    );
  }

  static String homeForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return '/admin';
      case UserRole.citizen:
        return '/citizen';
    }
  }
}

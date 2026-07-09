import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Renders the OneCitizen BD mark — agriculture, family and education
/// pillars framed in a hexagon.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 80,
    this.showLabel = false,
    this.onDark = false,
    this.linkToLanding = false,
  });

  final double size;
  final bool showLabel;
  final bool onDark;

  /// If true, tapping the logo signs the user out (if a session is active)
  /// and returns to the public landing page, so getting back into the
  /// citizen/admin area requires logging in again.
  final bool linkToLanding;

  @override
  Widget build(BuildContext context) {
    final logo = _buildLogo();
    if (!linkToLanding) return logo;
    return GestureDetector(
      onTap: () => _goToLanding(context),
      behavior: HitTestBehavior.opaque,
      child: logo,
    );
  }

  Future<void> _goToLanding(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (context.mounted) context.go('/home');
  }

  Widget _buildLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(size * 0.08),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: onDark
                ? null
                : [
                    BoxShadow(
                      color: AppTheme.primaryGreen.withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                      spreadRadius: -4,
                    ),
                  ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/images/logo.jpeg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (showLabel) ...[
          SizedBox(height: size * 0.16),
          Text(
            'OneCitizen BD',
            style: TextStyle(
              color: onDark ? Colors.white : AppTheme.textPrimary,
              fontSize: size * 0.2,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
              fontFamily: 'sans-serif',
            ),
          ),
        ],
      ],
    );
  }
}

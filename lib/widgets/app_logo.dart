import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';

/// Renders the OneCitizen BD mark — agriculture, family and education
/// pillars framed in a hexagon.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 80,
    this.showLabel = false,
    this.onDark = false,
  });

  final double size;
  final bool showLabel;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
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

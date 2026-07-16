import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/providers/locale_provider.dart';
import 'package:provider/provider.dart';

/// Small pill button that switches the app between Bangla and English.
/// Shows the language you'd switch *to*, matching common convention.
class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key, this.onDark = false});

  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LocaleProvider>().language;
    final isBangla = language == AppLanguage.bn;
    final foreground = onDark ? Colors.white : AppTheme.primaryGreen;

    return GestureDetector(
      onTap: () => context.read<LocaleProvider>().toggle(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: onDark ? Colors.white.withValues(alpha: 0.15) : AppTheme.primaryGreen.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: foreground.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.translate_rounded, size: 14, color: foreground),
            const SizedBox(width: 6),
            Text(
              isBangla ? 'English' : 'বাংলা',
              style: TextStyle(color: foreground, fontWeight: FontWeight.w700, fontSize: 12.5),
            ),
          ],
        ),
      ),
    );
  }
}

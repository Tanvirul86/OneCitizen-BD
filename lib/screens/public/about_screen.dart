import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/widgets/app_logo.dart';
import 'package:onecitizen/widgets/language_toggle.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: Text(context.tr('about')),
        actions: const [Padding(padding: EdgeInsets.only(right: 12), child: LanguageToggle())],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const AppLogo(size: 64, linkToLanding: true),
                    const SizedBox(height: 12),
                    Text(
                      'OneCitizen BD',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _InfoCard(
                child: Text(
                  context.tr('about_intro'),
                  style: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.6, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 20),
              _SectionCard(
                icon: Icons.person_rounded,
                color: AppTheme.primaryGreen,
                title: context.tr('about_citizens_title'),
                items: [
                  context.tr('about_citizens_item1'),
                  context.tr('about_citizens_item2'),
                  context.tr('about_citizens_item3'),
                  context.tr('about_citizens_item4'),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                icon: Icons.admin_panel_settings_rounded,
                color: AppTheme.infoBlue,
                title: context.tr('about_admins_title'),
                items: [
                  context.tr('about_admins_item1'),
                  context.tr('about_admins_item2'),
                  context.tr('about_admins_item3'),
                  context.tr('about_admins_item4'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: child,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.icon, required this.color, required this.title, required this.items});
  final IconData icon;
  final Color color;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: GoogleFonts.plusJakartaSans(fontSize: 13.5, height: 1.5, color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

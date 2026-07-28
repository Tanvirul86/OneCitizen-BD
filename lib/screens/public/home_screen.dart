import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/widgets/app_logo.dart';
import 'package:onecitizen/widgets/chatbot_widget.dart';
import 'package:onecitizen/widgets/language_toggle.dart';

// Accent colours used only on the public landing hero card fan / CTA — kept
// local instead of AppTheme since every other screen shares that palette.
const Color _landingGold = Color(0xFFB78B2E);
const Color _landingCream = Color(0xFFF2E6C8);

class PublicHomeScreen extends StatelessWidget {
  const PublicHomeScreen({super.key});

  static const _cards = [
    (
      icon: Icons.agriculture_rounded,
      titleKey: 'card_farmer_title',
      subtitleKey: 'card_farmer_subtitle',
      color: Color(0xFF059669),
      bgColor: Color(0xFFECFDF5),
    ),
    (
      icon: Icons.family_restroom_rounded,
      titleKey: 'card_family_title',
      subtitleKey: 'card_family_subtitle',
      color: Color(0xFF2563EB),
      bgColor: Color(0xFFEFF6FF),
    ),
    (
      icon: Icons.school_rounded,
      titleKey: 'card_education_title',
      subtitleKey: 'card_education_subtitle',
      color: Color(0xFF7C3AED),
      bgColor: Color(0xFFF5F3FF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      floatingActionButton: const ChatbotFab(),
      body: CustomScrollView(
        slivers: [
          // Transparent AppBar that overlays the hero
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: AppTheme.primaryGreenDark,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Row(
              children: [
                const AppLogo(size: 30, onDark: true, linkToLanding: true),
                const SizedBox(width: 10),
                Text(
                  'OneCitizen BD',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => context.push('/about'),
                child: Text(
                  context.tr('about'),
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const LanguageToggle(onDark: true),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero ──────────────────────────────────────────────────
                Container(
                  decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
                  child: Stack(
                    children: [
                      // Decorative blobs
                      Positioned(
                        right: -60,
                        top: 10,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                      Positioned(
                        left: -40,
                        bottom: -30,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 48),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(text: context.tr('hero_title_main')),
                                  TextSpan(
                                    text: context.tr('hero_title_accent'),
                                    style: const TextStyle(color: _landingCream),
                                  ),
                                ],
                              ),
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.w800,
                                height: 1.15,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              context.tr('hero_subtitle'),
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withValues(alpha: 0.82),
                                fontSize: 14,
                                height: 1.6,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    onPressed: () => context.push('/register'),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _landingCream,
                                      foregroundColor: AppTheme.primaryGreenDark,
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      textStyle: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    child: Text(context.tr('create_account')),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => context.push('/login'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.5),
                                        width: 1.5,
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 15),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      textStyle: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                    ),
                                    child: Text(context.tr('sign_in')),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),
                            const _HeroCardFan(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Stats strip ───────────────────────────────────────────
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  child: Row(
                    children: [
                      _StatItem(value: '3', label: context.tr('stat_card_types')),
                      _vDivider(),
                      _StatItem(value: '100%', label: context.tr('stat_digital')),
                      _vDivider(),
                      _StatItem(value: context.tr('stat_free'), label: context.tr('stat_service')),
                    ],
                  ),
                ),

                // ── Welfare Cards ─────────────────────────────────────────
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.tr('cards_section_eyebrow'),
                            style: GoogleFonts.ibmPlexMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.6,
                              color: _landingGold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.tr('available_cards_title'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.tr('available_cards_subtitle'),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...List.generate(_cards.length, (i) {
                      final card = _cards[i];
                      return Container(
                        width: double.infinity,
                        margin: EdgeInsets.fromLTRB(24, 0, 24, i < _cards.length - 1 ? 12 : 0),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: card.bgColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(card.icon, color: card.color, size: 26),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              context.tr(card.titleKey),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              context.tr(card.subtitleKey),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.plusJakartaSans(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),

                // ── Welcome banner ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        Text(
                          context.tr('welcome_banner_title'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          context.tr('welcome_banner_subtitle'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white.withValues(alpha: 0.78),
                            fontSize: 13.5,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: () => context.push('/register'),
                          style: FilledButton.styleFrom(
                            backgroundColor: _landingCream,
                            foregroundColor: AppTheme.primaryGreenDark,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          child: Text(context.tr('create_account')),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Footer ────────────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  color: AppTheme.primaryGreenDark,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const AppLogo(size: 44, onDark: true, linkToLanding: true),
                      const SizedBox(height: 12),
                      Text(
                        'OneCitizen BD',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.tr('footer_tagline'),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Divider(color: Colors.white.withValues(alpha: 0.15)),
                      const SizedBox(height: 12),
                      Text(
                        context.tr('footer_copyright'),
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.4),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 36,
        color: AppTheme.divider,
      );
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


/// Fanned-out preview of the three welfare cards, shown under the hero CTAs.
class _HeroCardFan extends StatelessWidget {
  const _HeroCardFan();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // Explicit width is required: without it the Stack shrink-wraps to
      // its widest child (one card) instead of the full hero width, so the
      // translated side cards end up left-aligned and clipped off-screen
      // instead of fanned out around the center.
      width: double.infinity,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.translate(
            offset: const Offset(-64, 6),
            child: Transform.rotate(
              angle: -0.19,
              child: const _MiniCard(
                gradientColors: [Color(0xFF0B7A55), Color(0xFF03301F)],
                titleKey: 'card_farmer_title',
                maskedNumber: '7213 9•••',
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(64, 6),
            child: Transform.rotate(
              angle: 0.19,
              child: const _MiniCard(
                gradientColors: [Color(0xFF1F5FA8), Color(0xFF0B2545)],
                titleKey: 'card_family_title',
                maskedNumber: '5480 2•••',
              ),
            ),
          ),
          const _MiniCard(
            gradientColors: [Color(0xFF6A3FA0), Color(0xFF2A1345)],
            titleKey: 'card_education_title',
            maskedNumber: '9061 4•••',
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({
    required this.gradientColors,
    required this.titleKey,
    required this.maskedNumber,
  });

  final List<Color> gradientColors;
  final String titleKey;
  final String maskedNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 168,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _landingCream.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GOVT OF BANGLADESH',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.ibmPlexMono(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 7.5,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr(titleKey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 26,
            height: 19,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_landingCream, _landingGold],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            maskedNumber,
            style: GoogleFonts.ibmPlexMono(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 9.5,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

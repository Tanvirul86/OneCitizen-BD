import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadAnalytics();
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 👋';
    if (hour < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AdminProvider>();
    final user = context.watch<AuthProvider>().user;
    final analytics = provider.analytics ?? {};

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      body: provider.isLoadingAnalytics && provider.analytics == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              color: AppTheme.primaryGreen,
              onRefresh: () => provider.loadAnalytics(),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // ── Hero header ─────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                    decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
                    child: Stack(
                      children: [
                        Positioned(
                          top: -30,
                          right: -30,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.fullName.isNotEmpty == true ? user!.fullName : 'Administrator',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: _HeroStat(
                                    label: 'Pending Applications',
                                    value: '${analytics['pending_review'] ?? 0}',
                                  ),
                                ),
                                Container(width: 1, height: 34, color: Colors.white.withValues(alpha: 0.2)),
                                Expanded(
                                  child: _HeroStat(
                                    label: 'Docs to Review',
                                    value: '${analytics['pending_document_reviews'] ?? 0}',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Stat cards ──────────────────────────────────
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.1,
                          children: [
                            _StatCard(
                              label: 'Total Applications',
                              value: '${analytics['total_applications'] ?? 0}',
                              icon: Icons.assignment_rounded,
                              color: AppTheme.primaryGreen,
                            ),
                            _StatCard(
                              label: 'Approved',
                              value: '${analytics['approved'] ?? 0}',
                              icon: Icons.check_circle_rounded,
                              color: AppTheme.successGreen,
                            ),
                            _StatCard(
                              label: 'Pending Review',
                              value: '${analytics['pending_review'] ?? 0}',
                              icon: Icons.hourglass_empty_rounded,
                              color: AppTheme.warningAmber,
                            ),
                            _StatCard(
                              label: 'Total Disbursed',
                              value: '৳${analytics['total_disbursed'] ?? 0}',
                              icon: Icons.payments_rounded,
                              color: AppTheme.infoBlue,
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // ── Quick actions ────────────────────────────────
                        Text(
                          'Quick Actions',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.92,
                          children: [
                            _ActionCard(
                              icon: Icons.assignment_rounded,
                              title: 'New Applications',
                              subtitle: 'Review & decide',
                              gradient: const LinearGradient(
                                colors: [AppTheme.primaryGreenDark, AppTheme.primaryGreenLight],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              onTap: () => context.go('/admin/applications'),
                            ),
                            _ActionCard(
                              icon: Icons.fact_check_rounded,
                              title: 'Document Validation',
                              subtitle: 'Verify uploads',
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0369A1), Color(0xFF0EA5E9)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              onTap: () => context.go('/admin/documents'),
                            ),
                            _ActionCard(
                              icon: Icons.credit_card_rounded,
                              title: 'Approved Cards',
                              subtitle: 'View issued cards',
                              gradient: const LinearGradient(
                                colors: [Color(0xFFBE185D), Color(0xFFEC4899)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              onTap: () => context.go('/admin/approved-cards'),
                            ),
                            _ActionCard(
                              icon: Icons.payments_rounded,
                              title: 'Fund Distribution',
                              subtitle: 'Disburse funds',
                              gradient: const LinearGradient(
                                colors: [Color(0xFF5B21B6), Color(0xFF8B5CF6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              onTap: () => context.go('/admin/distributions/new'),
                            ),
                            _ActionCard(
                              icon: Icons.receipt_long_rounded,
                              title: 'Distribution Records',
                              subtitle: 'Disbursement history',
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB45309), Color(0xFFF59E0B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              onTap: () => context.go('/admin/distributions'),
                            ),
                            _ActionCard(
                              icon: Icons.people_rounded,
                              title: 'Citizen Accounts',
                              subtitle: 'Manage citizens',
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              onTap: () => context.go('/admin/citizens'),
                            ),
                            _ActionCard(
                              icon: Icons.bar_chart_rounded,
                              title: 'Analytics',
                              subtitle: 'Program insights',
                              gradient: const LinearGradient(
                                colors: [Color(0xFF334155), Color(0xFF64748B)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              onTap: () => context.go('/admin/analytics'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
          ),
          Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

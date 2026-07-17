import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/config/routes.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/widgets/app_logo.dart';
import 'package:onecitizen/widgets/language_toggle.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.citizen;
  bool _isLoading = false;
  bool _obscure = true;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      role: _role,
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      context.go(AppRouter.homeForRole(auth.user!.role));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? context.trs('login_failed')),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    // Top half — green brand area
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: AppTheme.heroGradient,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(24, 36, 24, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const AppLogo(size: 56, onDark: true, linkToLanding: true),
                              const LanguageToggle(onDark: true),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            context.tr('welcome_back'),
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.tr('login_subtitle'),
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bottom half — form
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Role selector
                            Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  _RoleButton(
                                    icon: Icons.person_rounded,
                                    label: context.tr('role_citizen'),
                                    selected: _role == UserRole.citizen,
                                    onTap: () => setState(() => _role = UserRole.citizen),
                                  ),
                                  _RoleButton(
                                    icon: Icons.admin_panel_settings_rounded,
                                    label: context.tr('role_admin'),
                                    selected: _role == UserRole.admin,
                                    onTap: () => setState(() => _role = UserRole.admin),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 28),

                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      labelText: context.tr('email_label'),
                                      prefixIcon: const Icon(Icons.email_outlined),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.isEmpty) ? context.trs('email_required_login') : null,
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscure,
                                    decoration: InputDecoration(
                                      labelText: context.tr('password_label'),
                                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: AppTheme.textSecondary,
                                        ),
                                        onPressed: () => setState(() => _obscure = !_obscure),
                                      ),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.isEmpty) ? context.trs('password_required') : null,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 28),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        context.tr('sign_in'),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 16,
                                        ),
                                      ),
                              ),
                            ),

                            if (_role == UserRole.citizen) ...[
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    context.tr('no_account'),
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.push('/register'),
                                    child: Text(
                                      context.tr('register_link'),
                                      style: GoogleFonts.plusJakartaSans(
                                        color: AppTheme.primaryGreen,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],

                            const Spacer(),
                            GestureDetector(
                              onTap: () => context.go('/home'),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.arrow_back_rounded,
                                    size: 16,
                                    color: AppTheme.textTertiary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    context.tr('back_to_home'),
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppTheme.textTertiary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: selected ? AppTheme.elevatedShadow : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? Colors.white : AppTheme.textSecondary,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: selected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

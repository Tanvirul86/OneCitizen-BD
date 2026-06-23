import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/config/routes.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 6-digit OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();

    try {
      final success = await auth.verifyOtp(_otpController.text);
      if (mounted && success) {
        if (await auth.needsProfileSetup()) {
          context.go('/profile-setup');
        } else {
          context.go(AppRouter.homeForRole(auth.user!.role));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Invalid OTP'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.surfaceLight,
      appBar: AppBar(
        title: const Text('Verify OTP'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.message,
                  size: 80,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Enter Verification Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'We sent a 6-digit code to\n${auth.phoneNumber ?? "your phone"}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: const InputDecoration(
                    hintText: '000000',
                    counterText: '',
                  ),
                  onChanged: (value) {
                    if (value.length == 6) {
                      _verifyOtp();
                    }
                  },
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () async {
                    final phone = context.read<AuthProvider>().phoneNumber;
                    if (phone == null) return;
                    await context.read<AuthProvider>().sendOtp(phone);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('OTP resent successfully')),
                      );
                    }
                  },
                  child: const Text("Didn't receive code? Resend"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

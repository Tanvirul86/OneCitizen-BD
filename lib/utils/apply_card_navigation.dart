import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:onecitizen/l10n/app_strings.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:provider/provider.dart';

/// Routes to the apply-for-card flow, or to profile completion first if the
/// citizen's profile isn't complete yet — applications rely on profile
/// fields (address, occupation, DOB) for eligibility checks.
void goToApplyCard(BuildContext context) {
  final user = context.read<AuthProvider>().user;
  if (user != null && !user.profileComplete) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.trs('complete_profile_before_apply'))),
    );
    context.push('/citizen/profile-completion');
    return;
  }
  context.push('/citizen/apply');
}

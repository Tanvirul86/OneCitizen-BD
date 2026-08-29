import 'package:flutter/material.dart';
import 'package:onecitizen/l10n/app_strings.dart';

/// A time-of-day greeting ("Good morning"/"afternoon"/"evening") based on
/// the device's current local hour — shared by every dashboard so they
/// can't drift out of sync with each other.
String greetingFor(BuildContext context) {
  final hour = DateTime.now().hour;
  if (hour < 12) return context.tr('greeting_morning');
  if (hour < 17) return context.tr('greeting_afternoon');
  return context.tr('greeting_evening');
}

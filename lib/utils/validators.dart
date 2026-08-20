final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
final _bdPhoneRegex = RegExp(r'^01[3-9]\d{8}$');

bool isValidEmail(String value) => _emailRegex.hasMatch(value.trim());

bool isValidBdPhone(String value) => _bdPhoneRegex.hasMatch(value.trim());

/// Parses a strict `dd/MM/yyyy` string, rejecting anything that doesn't
/// round-trip exactly (e.g. `31/02/2020` silently rolling over to March).
DateTime? parseDdMmYyyy(String value) {
  final parts = value.trim().split('/');
  if (parts.length != 3) return null;
  final day = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final year = int.tryParse(parts[2]);
  if (day == null || month == null || year == null) return null;
  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) return null;
  return date;
}

int ageInYears(DateTime dateOfBirth, {DateTime? now}) {
  final today = now ?? DateTime.now();
  var age = today.year - dateOfBirth.year;
  if (today.month < dateOfBirth.month ||
      (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
    age--;
  }
  return age;
}

enum Occupation { farmer, student, serviceHolder, business, housewife, unemployed, other }

/// Returns null (instead of a fallback) so a blank/unrecognized value leaves
/// the dropdown unselected rather than silently picking a default occupation.
Occupation? occupationFromString(String? value) {
  switch (value?.toLowerCase()) {
    case 'farmer':
      return Occupation.farmer;
    case 'student':
      return Occupation.student;
    case 'service_holder':
    case 'serviceholder':
    case 'employee':
      return Occupation.serviceHolder;
    case 'business':
      return Occupation.business;
    case 'housewife':
      return Occupation.housewife;
    case 'unemployed':
      return Occupation.unemployed;
    case 'other':
      return Occupation.other;
    default:
      return null;
  }
}

String occupationToString(Occupation occupation) {
  switch (occupation) {
    case Occupation.farmer:
      return 'farmer';
    case Occupation.student:
      return 'student';
    case Occupation.serviceHolder:
      return 'service_holder';
    case Occupation.business:
      return 'business';
    case Occupation.housewife:
      return 'housewife';
    case Occupation.unemployed:
      return 'unemployed';
    case Occupation.other:
      return 'other';
  }
}

String occupationLabel(Occupation occupation) {
  switch (occupation) {
    case Occupation.farmer:
      return 'Farmer';
    case Occupation.student:
      return 'Student';
    case Occupation.serviceHolder:
      return 'Service Holder';
    case Occupation.business:
      return 'Business';
    case Occupation.housewife:
      return 'Housewife';
    case Occupation.unemployed:
      return 'Unemployed';
    case Occupation.other:
      return 'Other';
  }
}

class ApiConfig {
  static const String baseUrl = 'https://api.onecitizen.bd/api';

  // Auth
  static const String firebaseTokenExchange = '/auth/firebase/';
  static const String refreshToken = '/auth/token/refresh/';
  static const String me = '/auth/me/';
  static const String profile = '/auth/profile/';

  // Citizen
  static const String cards = '/cards/';
  static const String applications = '/applications/';
  static const String eligibilityCheck = '/eligibility/check/';
  static const String complaints = '/complaints/';
  static const String cardTypes = '/card-types/';

  // Officer
  static const String officerApplications = '/officer/applications/';
  static const String officerVerify = '/officer/verify/';

  // Admin
  static const String adminUsers = '/admin/users/';
  static const String adminOfficers = '/admin/officers/';
  static const String adminCardTypes = '/admin/card-types/';
  static const String adminComplaints = '/admin/complaints/';
  static const String adminLogs = '/admin/logs/';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

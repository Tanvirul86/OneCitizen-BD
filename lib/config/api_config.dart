class ApiConfig {
  static const String baseUrl = 'https://api.onecitizen.bd/api';

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String changePassword = '/auth/password';

  // Citizen — profile & documents
  static const String citizenProfile = '/citizen/profile';
  static const String citizenDocuments = '/citizen/documents';

  // Citizen — eligibility & applications
  static const String citizenEligibility = '/citizen/eligibility';
  static const String citizenApplications = '/citizen/applications';

  // Citizen — distribution & notifications
  static const String citizenDistributions = '/citizen/distributions';
  static const String citizenNotifications = '/citizen/notifications';

  // Card types (public, used by eligibility & application forms)
  static const String cardTypes = '/card-types';

  // Admin — applications
  static const String adminApplications = '/admin/applications';

  // Admin — document validation
  static const String adminDocuments = '/admin/documents';

  // Admin — fund distribution
  static const String adminDistributions = '/admin/distributions';

  // Admin — accounts & analytics
  static const String adminCitizens = '/admin/citizens';
  static const String adminAnalytics = '/admin/analytics';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

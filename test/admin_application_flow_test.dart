import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:onecitizen/config/api_config.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/services/admin_services.dart';
import 'package:onecitizen/services/api_client.dart';
import 'package:onecitizen/services/auth_service.dart';
import 'package:onecitizen/services/citizen_services.dart';
import 'package:onecitizen/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> mockLogin(ApiClient apiClient, String email) async {
    await apiClient.dio.post(
      ApiConfig.login,
      data: {'role': 'citizen', 'email': email, 'password': 'password123'},
    );
  }

  test('submitted citizen application appears in admin applications', () async {
    SharedPreferences.setMockInitialValues({});
    final storageService = StorageService();
    final apiClient = ApiClient(storageService: storageService);
    final applicationService = ApplicationService(apiClient: apiClient);
    final adminService = AdminService(apiClient: apiClient);

    final beforeAnalytics = await adminService.getAnalytics();
    final beforeTotal = beforeAnalytics['total_applications'] as int;
    final submitted = await applicationService.submitApplication(
      cardTypeId: 'ct-farmer',
    );

    final adminApplications = await adminService.getApplications();
    final adminApplication = adminApplications.firstWhere(
      (app) => app.id == submitted.id,
    );
    final afterAnalytics = await adminService.getAnalytics();

    expect(adminApplication.cardTypeId, submitted.cardTypeId);
    expect(adminApplication.cardTypeName, submitted.cardTypeName);
    expect(adminApplication.status, ApplicationStatus.submitted);
    expect(afterAnalytics['total_applications'], beforeTotal + 1);
    expect(afterAnalytics['pending_review'], greaterThanOrEqualTo(1));
  });

  test(
    'new citizen account does not see another citizen application list',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storageService = StorageService();
      final apiClient = ApiClient(storageService: storageService);
      final authService = AuthService(
        apiClient: apiClient,
        storageService: storageService,
      );
      final applicationService = ApplicationService(apiClient: apiClient);

      await authService.register(
        firstName: 'First',
        lastName: 'Citizen',
        email: 'first@example.com',
        phone: '01710000001',
        password: 'password123',
      );
      await authService.register(
        firstName: 'Second',
        lastName: 'Citizen',
        email: 'second@example.com',
        phone: '01710000002',
        password: 'password123',
      );

      await mockLogin(apiClient, 'first@example.com');
      final firstApplication = await applicationService.submitApplication(
        cardTypeId: 'ct-family',
      );

      await mockLogin(apiClient, 'second@example.com');
      final secondApplications = await applicationService.getApplications();

      expect(
        secondApplications.where((app) => app.id == firstApplication.id),
        isEmpty,
      );
      expect(secondApplications, isEmpty);
    },
  );

  test(
    'admin document validation updates the selected citizen document',
    () async {
      SharedPreferences.setMockInitialValues({});
      final storageService = StorageService();
      final apiClient = ApiClient(storageService: storageService);
      final authService = AuthService(
        apiClient: apiClient,
        storageService: storageService,
      );
      final documentService = DocumentService(apiClient: apiClient);
      final adminService = AdminService(apiClient: apiClient);

      await authService.register(
        firstName: 'Doc',
        lastName: 'Owner',
        email: 'doc.owner@example.com',
        phone: '01710000003',
        password: 'password123',
      );
      await mockLogin(apiClient, 'doc.owner@example.com');

      final tempFile = await File(
        '${Directory.systemTemp.path}/onecitizen-test-doc.pdf',
      ).writeAsString('mock pdf bytes');
      final uploaded = await documentService.uploadDocument(
        docType: 'income_certificate',
        filePath: tempFile.path,
      );

      final adminDocs = await adminService.getPendingDocuments(
        citizenId: uploaded.citizenId,
      );
      expect(adminDocs.map((doc) => doc.id), contains(uploaded.id));

      await adminService.validateDocument(
        uploaded.id,
        isValid: false,
        remark: 'Please resubmit a clearer copy.',
      );
      final citizenDocs = await documentService.getDocuments();
      final updated = citizenDocs.firstWhere((doc) => doc.id == uploaded.id);

      expect(updated.isValid, isFalse);
      expect(updated.remark, 'Please resubmit a clearer copy.');
    },
  );
}

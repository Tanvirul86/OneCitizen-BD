import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:onecitizen/config/api_config.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/services/admin_services.dart';
import 'package:onecitizen/services/api_client.dart';
import 'package:onecitizen/services/citizen_services.dart';
import 'package:onecitizen/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('citizen request becomes an admin action and updates the citizen', () async {
    SharedPreferences.setMockInitialValues({});
    final apiClient = ApiClient(storageService: StorageService());
    final applications = ApplicationService(apiClient: apiClient);
    final admin = AdminService(apiClient: apiClient);
    final documents = DocumentService(apiClient: apiClient);
    final notifications = NotificationService(apiClient: apiClient);

    await apiClient.dio.post(
      ApiConfig.register,
      data: {
        'first_name': 'Workflow',
        'last_name': 'Citizen',
        'email': 'workflow.citizen@example.com',
        'phone': '01700000000',
        'password': 'citizen-password',
      },
    );
    await apiClient.dio.post(
      ApiConfig.login,
      data: {
        'role': 'citizen',
        'email': 'workflow.citizen@example.com',
        'password': 'citizen-password',
      },
    );

    final uploadFile = File(
      '${Directory.systemTemp.path}/onecitizen-workflow-document.pdf',
    );
    await uploadFile.writeAsString('local workflow document');
    await documents.uploadDocument(
      docType: 'nid_copy',
      filePath: uploadFile.path,
    );

    final submitted = await applications.submitApplication(
      cardTypeId: 'farmer',
      applicationData: const {},
    );
    expect(submitted.status, ApplicationStatus.submitted);

    await apiClient.dio.post(
      ApiConfig.login,
      data: {
        'role': 'admin',
        'email': 'admin@gmail.com',
        'password': 'admin123',
      },
    );
    final received = await admin.getApplications();
    expect(received.map((application) => application.id), contains(submitted.id));

    final pendingDocuments = await admin.getPendingDocuments();
    expect(pendingDocuments.map((document) => document.docType), contains('nid_copy'));

    await admin.validateDocument(
      pendingDocuments.single.id,
      isValid: false,
      remark: 'Please upload a clearer NID copy.',
    );
    expect(await admin.getPendingDocuments(), isEmpty);

    await apiClient.dio.post(
      ApiConfig.login,
      data: {
        'role': 'citizen',
        'email': 'workflow.citizen@example.com',
        'password': 'citizen-password',
      },
    );
    final citizenApplications = await applications.getApplications();
    final citizenDocuments = await documents.getDocuments();

    expect(citizenApplications.single.status, ApplicationStatus.rejected);
    expect(citizenDocuments.single.applicationId, submitted.id);
    expect(citizenDocuments.single.isValid, isFalse);

    await documents.uploadDocument(
      docType: 'nid_copy',
      filePath: uploadFile.path,
      applicationId: submitted.id,
    );
    expect((await applications.getApplications()).single.status, ApplicationStatus.underReview);

    await apiClient.dio.post(
      ApiConfig.login,
      data: {
        'role': 'admin',
        'email': 'admin@gmail.com',
        'password': 'admin123',
      },
    );
    expect((await admin.getPendingDocuments()).single.docType, 'nid_copy');

    await admin.approveApplication(submitted.id);
    await apiClient.dio.post(
      ApiConfig.login,
      data: {
        'role': 'citizen',
        'email': 'workflow.citizen@example.com',
        'password': 'citizen-password',
      },
    );
    expect(await notifications.getNotifications(), isNotEmpty);
  });
}

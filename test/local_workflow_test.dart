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

    await admin.approveApplication(submitted.id);

    await apiClient.dio.post(
      ApiConfig.login,
      data: {
        'role': 'citizen',
        'email': 'workflow.citizen@example.com',
        'password': 'citizen-password',
      },
    );
    final citizenApplications = await applications.getApplications();
    final citizenNotifications = await notifications.getNotifications();

    expect(citizenApplications.single.status, ApplicationStatus.approved);
    expect(citizenNotifications, isNotEmpty);
  });
}

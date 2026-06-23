import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/config/routes.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/providers/card_provider.dart';
import 'package:onecitizen/providers/complaint_provider.dart';
import 'package:onecitizen/providers/officer_provider.dart';
import 'package:onecitizen/services/api_client.dart';
import 'package:onecitizen/services/citizen_services.dart';
import 'package:onecitizen/services/officer_admin_services.dart';
import 'package:onecitizen/services/storage_service.dart';
import 'package:provider/provider.dart';

class OneCitizenApp extends StatelessWidget {
  const OneCitizenApp({super.key, required this.authProvider});

  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    final storageService = StorageService();
    final apiClient = ApiClient(storageService: storageService);
    final cardService = CardService(apiClient: apiClient);
    final applicationService = ApplicationService(apiClient: apiClient);
    final eligibilityService = EligibilityService(apiClient: apiClient);
    final complaintService = ComplaintService(apiClient: apiClient);
    final cardTypeService = CardTypeService(apiClient: apiClient);
    final officerService = OfficerService(apiClient: apiClient);
    final adminService = AdminService(apiClient: apiClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(
          create: (_) => CardProvider(cardService: cardService),
        ),
        ChangeNotifierProvider(
          create: (_) => ApplicationProvider(
            applicationService: applicationService,
            cardTypeService: cardTypeService,
            eligibilityService: eligibilityService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ComplaintProvider(complaintService: complaintService),
        ),
        ChangeNotifierProvider(
          create: (_) => OfficerProvider(officerService: officerService),
        ),
        ChangeNotifierProvider(
          create: (_) => AdminProvider(adminService: adminService),
        ),
      ],
      child: MaterialApp.router(
        title: 'OneCitizen BD',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        routerConfig: AppRouter.create(authProvider),
      ),
    );
  }
}

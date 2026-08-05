import 'package:flutter/material.dart';
import 'package:onecitizen/config/app_theme.dart';
import 'package:onecitizen/config/routes.dart';
import 'package:onecitizen/providers/admin_provider.dart';
import 'package:onecitizen/providers/application_provider.dart';
import 'package:onecitizen/providers/auth_provider.dart';
import 'package:onecitizen/providers/distribution_provider.dart';
import 'package:onecitizen/providers/notification_provider.dart';
import 'package:onecitizen/services/admin_services.dart';
import 'package:onecitizen/services/citizen_services.dart';
import 'package:provider/provider.dart';

class OneCitizenApp extends StatelessWidget {
  const OneCitizenApp({super.key, required this.authProvider});

  final AuthProvider authProvider;

  @override
  Widget build(BuildContext context) {
    final cardTypeService = CardTypeService();
    final applicationService = ApplicationService();
    final eligibilityService = EligibilityService();
    final documentService = DocumentService();
    final distributionService = DistributionService();
    final notificationService = NotificationService();
    final adminService = AdminService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(
          create: (_) => ApplicationProvider(
            applicationService: applicationService,
            cardTypeService: cardTypeService,
            eligibilityService: eligibilityService,
            documentService: documentService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DistributionProvider(distributionService: distributionService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(notificationService: notificationService),
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

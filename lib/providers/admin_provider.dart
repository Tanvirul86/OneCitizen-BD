import 'package:flutter/foundation.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/models/distribution.dart';
import 'package:onecitizen/models/document.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/services/admin_services.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider({required AdminService adminService}) : _adminService = adminService;

  final AdminService _adminService;

  // Applications
  List<Application> applications = [];
  Application? selectedApplication;
  bool isLoadingApplications = false;
  String? applicationsError;

  Future<void> loadApplications({String? cardTypeId, ApplicationStatus? status}) async {
    isLoadingApplications = true;
    applicationsError = null;
    notifyListeners();
    try {
      applications = await _adminService.getApplications(cardTypeId: cardTypeId, status: status);
    } catch (e) {
      applicationsError = e.toString();
    } finally {
      isLoadingApplications = false;
      notifyListeners();
    }
  }

  Future<void> loadApplicationDetail(String id) async {
    isLoadingApplications = true;
    notifyListeners();
    try {
      selectedApplication = await _adminService.getApplication(id);
    } catch (e) {
      applicationsError = e.toString();
    } finally {
      isLoadingApplications = false;
      notifyListeners();
    }
  }

  Future<bool> approveApplication(String id) async {
    try {
      selectedApplication = await _adminService.approveApplication(id);
      _replaceApplication(selectedApplication!);
      notifyListeners();
      return true;
    } catch (e) {
      applicationsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> rejectApplication(String id, {required String reason}) async {
    try {
      selectedApplication = await _adminService.rejectApplication(id, reason: reason);
      _replaceApplication(selectedApplication!);
      notifyListeners();
      return true;
    } catch (e) {
      applicationsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _replaceApplication(Application app) {
    final idx = applications.indexWhere((a) => a.id == app.id);
    if (idx >= 0) applications[idx] = app;
  }

  // Document validation
  List<CitizenDocument> pendingDocuments = [];
  bool isLoadingDocuments = false;
  String? documentsError;

  Future<void> loadPendingDocuments() async {
    isLoadingDocuments = true;
    documentsError = null;
    notifyListeners();
    try {
      pendingDocuments = await _adminService.getPendingDocuments();
    } catch (e) {
      documentsError = e.toString();
    } finally {
      isLoadingDocuments = false;
      notifyListeners();
    }
  }

  Future<bool> validateDocument(String id, {required bool isValid, String? remark}) async {
    try {
      final doc = await _adminService.validateDocument(id, isValid: isValid, remark: remark);
      final idx = pendingDocuments.indexWhere((d) => d.id == id);
      if (idx >= 0) pendingDocuments[idx] = doc;
      notifyListeners();
      return true;
    } catch (e) {
      documentsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Fund distribution
  List<Distribution> distributions = [];
  bool isLoadingDistributions = false;
  String? distributionsError;

  Future<void> loadDistributions({String? cardTypeId, DistributionMethod? method}) async {
    isLoadingDistributions = true;
    distributionsError = null;
    notifyListeners();
    try {
      distributions = await _adminService.getDistributions(cardTypeId: cardTypeId, method: method);
    } catch (e) {
      distributionsError = e.toString();
    } finally {
      isLoadingDistributions = false;
      notifyListeners();
    }
  }

  Future<bool> createDistribution({
    required String applicationId,
    required DistributionMethod method,
    required double amount,
    String? note,
  }) async {
    try {
      final dist = await _adminService.createDistribution(
        applicationId: applicationId,
        method: method,
        amount: amount,
        note: note,
      );
      distributions.insert(0, dist);
      notifyListeners();
      return true;
    } catch (e) {
      distributionsError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Citizen accounts
  List<User> citizens = [];
  bool isLoadingCitizens = false;
  String? citizensError;

  Future<void> loadCitizens({String? search}) async {
    isLoadingCitizens = true;
    citizensError = null;
    notifyListeners();
    try {
      citizens = await _adminService.getCitizens(search: search);
    } catch (e) {
      citizensError = e.toString();
    } finally {
      isLoadingCitizens = false;
      notifyListeners();
    }
  }

  Future<bool> deactivateCitizen(String id) async {
    try {
      await _adminService.deactivateCitizen(id);
      await loadCitizens();
      return true;
    } catch (e) {
      citizensError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> activateCitizen(String id) async {
    try {
      await _adminService.activateCitizen(id);
      await loadCitizens();
      return true;
    } catch (e) {
      citizensError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> freezeCitizen(String id) async {
    try {
      await _adminService.freezeCitizen(id);
      await loadCitizens();
      return true;
    } catch (e) {
      citizensError = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> unfreezeCitizen(String id) async {
    try {
      await _adminService.unfreezeCitizen(id);
      await loadCitizens();
      return true;
    } catch (e) {
      citizensError = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Analytics
  Map<String, dynamic>? analytics;
  bool isLoadingAnalytics = false;
  String? analyticsError;

  Future<void> loadAnalytics() async {
    isLoadingAnalytics = true;
    analyticsError = null;
    notifyListeners();
    try {
      analytics = await _adminService.getAnalytics();
    } catch (e) {
      analyticsError = e.toString();
    } finally {
      isLoadingAnalytics = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/services/officer_admin_services.dart';

class OfficerProvider extends ChangeNotifier {
  OfficerProvider({required OfficerService officerService})
      : _officerService = officerService;

  final OfficerService _officerService;

  List<Application> applications = [];
  Application? selectedApplication;
  Map<String, dynamic>? verificationResult;
  bool isLoading = false;
  String? error;
  String searchQuery = '';

  Future<void> loadApplications({ApplicationStatus? filter}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      applications = await _officerService.getPendingApplications(
        search: searchQuery.isNotEmpty ? searchQuery : null,
        status: filter,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadApplicationDetail(String id) async {
    isLoading = true;
    notifyListeners();

    try {
      selectedApplication = await _officerService.getApplicationDetail(id);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateStatus({
    required String id,
    required ApplicationStatus status,
    String? remarks,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final updated = await _officerService.updateApplicationStatus(
        id: id,
        status: status,
        remarks: remarks,
      );
      final idx = applications.indexWhere((a) => a.id == id);
      if (idx >= 0) applications[idx] = updated;
      selectedApplication = updated;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> verifyCitizen(String nid) async {
    isLoading = true;
    notifyListeners();

    try {
      verificationResult = await _officerService.verifyCitizen(nid: nid);
    } catch (e) {
      error = e.toString();
      verificationResult = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }
}

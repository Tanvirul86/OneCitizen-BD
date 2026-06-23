import 'package:flutter/foundation.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/models/card_type.dart';
import 'package:onecitizen/services/citizen_services.dart';

class ApplicationProvider extends ChangeNotifier {
  ApplicationProvider({
    required ApplicationService applicationService,
    required CardTypeService cardTypeService,
    required EligibilityService eligibilityService,
  })  : _applicationService = applicationService,
        _cardTypeService = cardTypeService,
        _eligibilityService = eligibilityService;

  final ApplicationService _applicationService;
  final CardTypeService _cardTypeService;
  final EligibilityService _eligibilityService;

  List<Application> applications = [];
  List<CardType> cardTypes = [];
  EligibilityResult? eligibilityResult;
  bool isLoading = false;
  String? error;

  Future<void> loadApplications() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      applications = await _applicationService.getApplications();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCardTypes() async {
    try {
      cardTypes = await _cardTypeService.getCardTypes();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> submitApplication({
    required String cardTypeId,
    required Map<String, String> documents,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final app = await _applicationService.submitApplication(
        cardTypeId: cardTypeId,
        documentPaths: documents,
      );
      applications.insert(0, app);
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

  Application? selectedApplication;
  bool isLoadingDetail = false;
  String? detailError;

  Future<void> loadApplicationById(String id) async {
    isLoadingDetail = true;
    detailError = null;
    notifyListeners();
    try {
      selectedApplication = await _applicationService.getApplication(id);
    } catch (e) {
      detailError = e.toString();
    } finally {
      isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> checkEligibility({
    required String occupation,
    required double income,
    required int age,
    double? landHolding,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      eligibilityResult = await _eligibilityService.checkEligibility(
        occupation: occupation,
        income: income,
        age: age,
        landHolding: landHolding,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

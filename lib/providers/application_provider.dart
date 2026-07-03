import 'package:flutter/foundation.dart';
import 'package:onecitizen/models/application.dart';
import 'package:onecitizen/models/card_type.dart';
import 'package:onecitizen/models/document.dart';
import 'package:onecitizen/services/citizen_services.dart';

class ApplicationProvider extends ChangeNotifier {
  ApplicationProvider({
    required ApplicationService applicationService,
    required CardTypeService cardTypeService,
    required EligibilityService eligibilityService,
    required DocumentService documentService,
  })  : _applicationService = applicationService,
        _cardTypeService = cardTypeService,
        _eligibilityService = eligibilityService,
        _documentService = documentService;

  final ApplicationService _applicationService;
  final CardTypeService _cardTypeService;
  final EligibilityService _eligibilityService;
  final DocumentService _documentService;

  List<Application> applications = [];
  List<CardType> cardTypes = [];
  List<CitizenDocument> documents = [];
  EligibilityResult? eligibilityResult;
  bool isLoading = false;
  String? error;

  // Eligibility submission state
  String? eligibilityRequestStatus; // null | 'pending_review' | 'approved' | 'rejected'
  bool isSubmittingEligibility = false;
  String? eligibilitySubmitError;

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

  Future<void> loadDocuments() async {
    try {
      documents = await _documentService.getDocuments();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> uploadDocument({
    required String docType,
    required String filePath,
  }) async {
    try {
      final doc = await _documentService.uploadDocument(
        docType: docType,
        filePath: filePath,
      );
      final idx = documents.indexWhere((d) => d.docType == docType);
      if (idx >= 0) {
        documents[idx] = doc;
      } else {
        documents.add(doc);
      }
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitApplication({required String cardTypeId}) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final app = await _applicationService.submitApplication(cardTypeId: cardTypeId);
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

  void resetEligibilityRequest() {
    eligibilityRequestStatus = null;
    eligibilitySubmitError = null;
    notifyListeners();
  }

  Future<bool> submitEligibilityRequest(Map<String, dynamic> data) async {
    isSubmittingEligibility = true;
    eligibilitySubmitError = null;
    notifyListeners();
    try {
      final result = await _eligibilityService.submitEligibilityRequest(data);
      eligibilityRequestStatus = result['status'] as String? ?? 'pending_review';
      isSubmittingEligibility = false;
      notifyListeners();
      return true;
    } catch (e) {
      eligibilitySubmitError = e.toString();
      isSubmittingEligibility = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> checkEligibility() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      eligibilityResult = await _eligibilityService.checkEligibility();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:onecitizen/models/complaint.dart';
import 'package:onecitizen/services/citizen_services.dart';

class ComplaintProvider extends ChangeNotifier {
  ComplaintProvider({required ComplaintService complaintService})
      : _complaintService = complaintService;

  final ComplaintService _complaintService;

  List<Complaint> complaints = [];
  bool isLoading = false;
  String? error;

  Future<void> loadComplaints() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      complaints = await _complaintService.getComplaints();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitComplaint({
    required String subject,
    required String description,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final complaint = await _complaintService.submitComplaint(
        subject: subject,
        description: description,
      );
      complaints.insert(0, complaint);
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
}

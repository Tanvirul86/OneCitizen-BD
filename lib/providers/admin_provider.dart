import 'package:flutter/foundation.dart';
import 'package:onecitizen/models/card_type.dart';
import 'package:onecitizen/models/complaint.dart';
import 'package:onecitizen/models/user.dart';
import 'package:onecitizen/services/officer_admin_services.dart';

class AdminProvider extends ChangeNotifier {
  AdminProvider({required AdminService adminService})
      : _adminService = adminService;

  final AdminService _adminService;

  List<User> users = [];
  List<User> officers = [];
  List<CardType> cardTypes = [];
  List<Complaint> complaints = [];
  List<Map<String, dynamic>> logs = [];
  bool isLoading = false;
  String? error;

  Future<void> loadUsers() async {
    isLoading = true;
    notifyListeners();
    try {
      users = await _adminService.getUsers();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> suspendUser(String id) async {
    await _adminService.suspendUser(id);
    await loadUsers();
  }

  Future<void> reactivateUser(String id) async {
    await _adminService.reactivateUser(id);
    await loadUsers();
  }

  Future<void> deleteUser(String id) async {
    await _adminService.deleteUser(id);
    await loadUsers();
  }

  Future<void> loadCardTypes() async {
    isLoading = true;
    notifyListeners();
    try {
      cardTypes = await _adminService.getCardTypes();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCardType(String id) async {
    await _adminService.deleteCardType(id);
    await loadCardTypes();
  }

  Future<bool> saveCardType(CardType cardType, {String? id}) async {
    try {
      if (id != null) {
        await _adminService.updateCardType(id, cardType);
      } else {
        await _adminService.createCardType(cardType);
      }
      await loadCardTypes();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadOfficers() async {
    isLoading = true;
    notifyListeners();
    try {
      officers = await _adminService.getOfficers();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOfficer(String phone, String name) async {
    try {
      await _adminService.createOfficer(phoneNumber: phone, fullName: name);
      await loadOfficers();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> removeOfficer(String id) async {
    await _adminService.removeOfficer(id);
    await loadOfficers();
  }

  Future<void> loadComplaints() async {
    isLoading = true;
    notifyListeners();
    try {
      complaints = await _adminService.getAllComplaints();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> resolveComplaint(String id, String resolution) async {
    try {
      await _adminService.resolveComplaint(id: id, resolution: resolution);
      await loadComplaints();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadLogs() async {
    try {
      logs = await _adminService.getSystemLogs();
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}

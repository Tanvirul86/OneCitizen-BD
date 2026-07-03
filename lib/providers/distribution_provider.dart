import 'package:flutter/foundation.dart';
import 'package:onecitizen/models/distribution.dart';
import 'package:onecitizen/services/citizen_services.dart';

class DistributionProvider extends ChangeNotifier {
  DistributionProvider({required DistributionService distributionService})
      : _distributionService = distributionService;

  final DistributionService _distributionService;

  List<Distribution> distributions = [];
  bool isLoading = false;
  String? error;

  Future<void> loadDistributions() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      distributions = await _distributionService.getDistributions();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

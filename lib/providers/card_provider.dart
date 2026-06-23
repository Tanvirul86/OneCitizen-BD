import 'package:flutter/foundation.dart';
import 'package:onecitizen/models/card.dart';
import 'package:onecitizen/services/citizen_services.dart';

class CardProvider extends ChangeNotifier {
  CardProvider({required CardService cardService}) : _cardService = cardService;

  final CardService _cardService;

  List<CitizenCard> cards = [];
  CitizenCard? selectedCard;
  bool isLoading = false;
  bool isLoadingDetail = false;
  String? error;
  String? detailError;

  Future<void> loadCards() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      cards = await _cardService.getMyCards();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCardById(String id) async {
    isLoadingDetail = true;
    detailError = null;
    // Check local cache first
    final cached = cards.where((c) => c.id == id).firstOrNull;
    if (cached != null) {
      selectedCard = cached;
      isLoadingDetail = false;
      notifyListeners();
      return;
    }
    notifyListeners();
    try {
      selectedCard = await _cardService.getCard(id);
    } catch (e) {
      detailError = e.toString();
    } finally {
      isLoadingDetail = false;
      notifyListeners();
    }
  }
}

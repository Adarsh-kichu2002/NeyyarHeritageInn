import 'package:flutter/material.dart';

class QuotationHistoryStore extends ChangeNotifier {
  final List<Map<String, dynamic>> quotations = [];

  void addQuotation(Map<String, dynamic> q) {
    quotations.add({
      ...q,
      'id': DateTime.now().millisecondsSinceEpoch,
    });
    notifyListeners();
  }

  void deleteQuotationById(int id) {
    quotations.removeWhere((q) => q['id'] == id);
    notifyListeners();
  }
}

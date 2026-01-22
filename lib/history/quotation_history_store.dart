import 'package:flutter/material.dart';

class QuotationHistoryStore extends ChangeNotifier {
  final List<Map<String, dynamic>> _quotations = [];

  List<Map<String, dynamic>> get quotations =>
      List.unmodifiable(_quotations);

  /// ADD NEW QUOTATION
  void addQuotation(Map<String, dynamic> quotation) {
    final index = _quotations.length;

    _quotations.add({
      ...quotation,
      'historyIndex': index, // 🔑 STORE INDEX
    });

    notifyListeners();
  }

  /// UPDATE EXISTING QUOTATION
  void updateQuotation(int index, Map<String, dynamic> quotation) {
    if (index < 0 || index >= _quotations.length) return;

    _quotations[index] = {
      ...quotation,
      'historyIndex': index, // 🔑 PRESERVE INDEX
    };

    notifyListeners();
  }

  /// DELETE QUOTATION
  void deleteQuotation(int index) {
    if (index < 0 || index >= _quotations.length) return;

    _quotations.removeAt(index);

    /// REBUILD INDEXES AFTER DELETE
    for (int i = 0; i < _quotations.length; i++) {
      _quotations[i]['historyIndex'] = i;
    }

    notifyListeners();
  }
}

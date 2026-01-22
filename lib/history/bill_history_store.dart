import 'package:flutter/material.dart';

class BillHistoryStore extends ChangeNotifier {
  final List<Map<String, dynamic>> _bills = [];

  List<Map<String, dynamic>> get bills => List.unmodifiable(_bills);

  /// ADD BILL (NO DUPLICATION)
  void addBill(Map<String, dynamic> bill) {
    final existingIndex = _bills.indexWhere(
      (b) => b['invoiceNo'] == bill['invoiceNo'],
    );

    if (existingIndex != -1) {
      _bills[existingIndex] = {
        ...bill,
        'historyIndex': existingIndex,
      };
    } else {
      _bills.add({
        ...bill,
        'historyIndex': _bills.length,
      });
    }

    notifyListeners();
  }

  /// DELETE BILL
  void deleteBill(int index) {
    if (index < 0 || index >= _bills.length) return;

    _bills.removeAt(index);

    for (int i = 0; i < _bills.length; i++) {
      _bills[i]['historyIndex'] = i;
    }

    notifyListeners();
  }
}

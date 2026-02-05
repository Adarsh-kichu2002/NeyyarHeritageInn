import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillHistoryStore extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> _bills = [];
  bool isLoading = true;

  List<Map<String, dynamic>> get bills => _bills;

  BillHistoryStore() {
    _listenBills();
  }

  void _listenBills() {
    _db
        .collection('bills')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _bills
        ..clear()
        ..addAll(snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            ...data,
            'invoiceNo': doc.id,
            'checkInDate': (data['checkInDate'] as Timestamp?)?.toDate(),
            'checkOutDate': (data['checkOutDate'] as Timestamp?)?.toDate(),
          };
        }));
      isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addBill(Map<String, dynamic> bill) async {
    final invoiceNo = bill['invoiceNo'].toString();

    await _db.collection('bills').doc(invoiceNo).set({
      ...bill,
      'checkInDate': bill['checkInDate'],
      'checkOutDate': bill['checkOutDate'],
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteBill(String invoiceNo) async {
    await _db.collection('bills').doc(invoiceNo).delete();
  }
}

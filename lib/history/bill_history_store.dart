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
            'billId': doc.id, // 🔑 INTERNAL ID
            'checkInDate': (data['checkInDate'] as Timestamp?)?.toDate(),
            'checkOutDate': (data['checkOutDate'] as Timestamp?)?.toDate(),
          };
        }));

      isLoading = false;
      notifyListeners();
    });
  }

  /// ADD OR UPDATE BILL (NO DUPLICATES)
  Future<void> addOrUpdateBill(Map<String, dynamic> bill) async {
    // 🔐 Stable Firestore ID
    final billId = bill['billId'] ??
        DateTime.now().millisecondsSinceEpoch.toString();

    final docRef = _db.collection('bills').doc(billId);

    final snap = await docRef.get();

    await docRef.set({
      ...bill,
      'billId': billId,
      'checkInDate': bill['checkInDate'],
      'checkOutDate': bill['checkOutDate'],
      'invoiceNo': bill['invoiceNo'],
      'updatedAt': FieldValue.serverTimestamp(),

      // ⛔ createdAt only once
      if (!snap.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> deleteBill(String billId) async {
    await _db.collection('bills').doc(billId).delete();
  }
}

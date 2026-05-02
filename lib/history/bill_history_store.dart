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

  /// 🔥 REAL-TIME LISTENER
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
            'billId': doc.id, // 🔑 Firestore ID
            'checkInDate':
                (data['checkInDate'] as Timestamp?)?.toDate(),
            'checkOutDate':
                (data['checkOutDate'] as Timestamp?)?.toDate(),
          };
        }));

      isLoading = false;
      notifyListeners();
    });
  }

  /// 🧹 CLEAN ITEMS (REMOVE CONTROLLERS)
  List<Map<String, dynamic>> _cleanItems(List items) {
    return items.map((i) {
      return {
        'name': i['name'],
        'qty': i['qty'],
        'price': i['price'],
      };
    }).toList();
  }

  /// 📌 ADD OR UPDATE BILL (NO DUPLICATES)
  Future<void> addOrUpdateBill(Map<String, dynamic> bill) async {
    /// 🔥 MUST HAVE billId (no fallback → prevents duplicates)
    if (bill['billId'] == null) {
      throw Exception("billId is required to save bill");
    }

    final String billId = bill['billId'];

    final docRef = _db.collection('bills').doc(billId);
    final snap = await docRef.get();

    final cleanData = {
      ...bill,

      /// ✅ Clean items
      if (bill['items'] != null)
        'items': _cleanItems(bill['items']),

      /// ✅ Convert dates properly
      if (bill['checkInDate'] is DateTime)
        'checkInDate': Timestamp.fromDate(bill['checkInDate']),

      if (bill['checkOutDate'] is DateTime)
        'checkOutDate': Timestamp.fromDate(bill['checkOutDate']),

      /// ✅ Always keep billId consistent
      'billId': billId,

      /// ✅ Update timestamp
      'updatedAt': FieldValue.serverTimestamp(),

      /// ✅ Create timestamp only first time
      if (!snap.exists) 'createdAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(cleanData, SetOptions(merge: true));
  }

  /// ❌ DELETE BILL
  Future<void> deleteBill(String billId) async {
    await _db.collection('bills').doc(billId).delete();
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neyyar_heritage/screens/itinerary_history_tab.dart';

class ItineraryHistoryScreen extends StatefulWidget {
  const ItineraryHistoryScreen({super.key});

  @override
  State<ItineraryHistoryScreen> createState() => _ItineraryHistoryScreenState();
}

class _ItineraryHistoryScreenState extends State<ItineraryHistoryScreen> {
  DateTime? fromDate;
  DateTime? toDate;

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        isFrom ? fromDate = picked : toDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Query query = FirebaseFirestore.instance
        .collection('itineraries')
        .orderBy('checkInDate', descending: true);

    if (fromDate != null) {
      query = query.where(
        'checkInDate',
        isGreaterThanOrEqualTo: fromDate,
      );
    }
    if (toDate != null) {
      query = query.where(
        'checkInDate',
        isLessThanOrEqualTo: toDate,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Itinerary History')),
      body: Column(
        children: [
          /// 🔍 DATE FILTER
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(true),
                    child: Text(
                      fromDate == null
                          ? 'From Date'
                          : fromDate!.toString().split(' ').first,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _pickDate(false),
                    child: Text(
                      toDate == null
                          ? 'To Date'
                          : toDate!.toString().split(' ').first,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 📋 LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No itineraries found'));
                }

                return ItineraryHistoryTab(
                  docs: snapshot.data!.docs,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

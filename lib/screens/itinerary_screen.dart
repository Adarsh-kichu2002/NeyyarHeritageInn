import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:neyyar_heritage/screens/itinerary_history_tab.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {

  DateTime? selectedDate;

  /// Date Picker
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// Clear filter
  void _clearFilter() {
    setState(() {
      selectedDate = null;
    });
  }

  /// Firestore query based on filter
  Query getQuery() {
    final baseQuery = FirebaseFirestore.instance
        .collection('itineraries')
        .orderBy('date', descending: true);

    if (selectedDate == null) return baseQuery;

    final start = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day);

    final end = start.add(const Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('itineraries')
        .where('date', isGreaterThanOrEqualTo: start)
        .where('date', isLessThan: end)
        .orderBy('date', descending: true);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Itineraries"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _pickDate,
          ),
          if (selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearFilter,
            )
        ],
      ),

      body: Column(
        children: [

          /// Selected date indicator
          if (selectedDate != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: Colors.orange.shade100,
              child: Text(
                "Filtered Date : ${DateFormat('dd MMM yyyy').format(selectedDate!)}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

          /// Itinerary List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
  stream: getQuery().snapshots(),
  builder: (context, snapshot) {

    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    final now = DateTime.now();

    /// 🔴 FILTER LOGIC
    final docs = snapshot.data!.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final date = (data['date'] as Timestamp?)?.toDate();

      if (date == null) return false;

      /// If NO filter → hide past
      if (selectedDate == null) {
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
        return now.isBefore(endOfDay);
      }

      /// If filter applied → show all
      return true;
    }).toList();

    if (docs.isEmpty) {
      return const Center(child: Text("No itineraries found"));
    }

    return ItineraryHistoryTab(
      docs: docs,
      viewOnly: true,
    );
  },
),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../history/bill_history_store.dart';

class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  DateTime? from;
  DateTime? to;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<BillHistoryStore>();

    return Scaffold(
      backgroundColor: Colors.white, // ✅ FULL WHITE SCREEN

      appBar: AppBar(
        title: const Text('Bills'), // ✅ TITLE ADDED
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),

      body: store.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                /// FILTER
                Container(
                  color: Colors.white, // ✅ FIX FILTER BG
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      _dateBox('From', from, (d) => setState(() => from = d)),
                      const SizedBox(width: 8),
                      _dateBox('To', to, (d) => setState(() => to = d)),

                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.black),
                        onPressed: () => setState(() {}),
                      ),

                      if (from != null || to != null)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.black),
                          onPressed: () {
                            setState(() {
                              from = null;
                              to = null;
                            });
                          },
                        ),
                    ],
                  ),
                ),

                /// TABLE
                Expanded(
                  child: _buildTable(store),
                ),
              ],
            ),
    );
  }

  Widget _buildTable(BillHistoryStore store) {
    final filtered = store.bills.where((bill) {
      final DateTime? checkOut = bill['checkOutDate'];

      if (from == null && to == null) return true;
      if (checkOut == null) return false;

      if (from != null && checkOut.isBefore(_startOfDay(from!))) return false;
      if (to != null && checkOut.isAfter(_endOfDay(to!))) return false;

      return true;
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No bills found'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          color: Colors.white, // ✅ TABLE BG WHITE
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey.shade200),
            columns: const [
              DataColumn(label: Text('SI')),
              DataColumn(label: Text('Invoice')),
              DataColumn(label: Text('Guest')),
              DataColumn(label: Text('Phone')),
              DataColumn(label: Text('Check In')),
              DataColumn(label: Text('Check Out')),
              DataColumn(label: Text('Total')),
              DataColumn(label: Text('Actions')),
            ],
            rows: List.generate(filtered.length, (i) {
              final b = filtered[i];
              final hasPayment = b['payment'] != null;

              return DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                  (states) {
                    if (hasPayment) {
                      return const Color.fromARGB(255, 245, 221, 8); 
                    }
                    return Colors.white; // ✅ DEFAULT WHITE
                  },
                ),
                cells: [
                  DataCell(Text('${i + 1}')),
                  DataCell(Text('${b['invoiceNo']}')),
                  DataCell(Text(b['customerName'] ?? '')),
                  DataCell(Text('${b['phone1']}')),
                  DataCell(Text(_fmt(b['checkInDate']))),
                  DataCell(Text(_fmt(b['checkOutDate']))),
                  DataCell(Text('₹${b['balance']}')),

                  /// ACTIONS
                  DataCell(
                    Row(
                      children: [
                        /// VIEW
                        IconButton(
                          icon: const Icon(Icons.visibility,
                              color: Colors.green),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/bill_preview',
                              arguments: b,
                            );
                          },
                        ),

                        /// EDIT BILL
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/bill_screen',
                              arguments: {
                                ...b,
                                'isEdit': true,
                                'billId': b['billId'],
                              },
                            );
                          },
                        ),

                        /// PAYMENT (READ ONLY)
                        IconButton(
                          icon: const Icon(Icons.currency_rupee,
                              color: Colors.purple),
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/payment_screen',
                              arguments: {
                                ...b,
                                'isReadOnlyPayment': true,
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  /// ✅ FIXED DATE BUTTON (WHITE STYLE)
  Widget _dateBox(String label, DateTime? value, Function(DateTime) onPick) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        side: const BorderSide(color: Colors.grey),
      ),
      onPressed: () async {
        final d = await showDatePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
          initialDate: value ?? DateTime.now(),
        );
        if (d != null) onPick(d);
      },
      child: Text(
        value == null
            ? label
            : DateFormat('dd/MM/yyyy').format(value),
      ),
    );
  }

  String _fmt(DateTime? d) =>
      d == null ? '' : DateFormat('dd/MM/yyyy').format(d);

  DateTime _startOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59);
}

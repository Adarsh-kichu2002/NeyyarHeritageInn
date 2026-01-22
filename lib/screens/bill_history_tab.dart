import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../history/bill_history_store.dart';

class BillHistoryTab extends StatefulWidget {
  const BillHistoryTab({super.key});

  @override
  State<BillHistoryTab> createState() => _BillHistoryTabState();
}

class _BillHistoryTabState extends State<BillHistoryTab> {
  DateTime? from;
  DateTime? to;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<BillHistoryStore>();

    /// FILTER BY CHECK-OUT DATE
    final filtered = store.bills.asMap().entries.where((entry) {
      final bill = entry.value;
      final DateTime? checkOut = bill['checkOutDate'];

      if (checkOut == null) return false;

      if (from != null && checkOut.isBefore(_startOfDay(from!))) {
        return false;
      }
      if (to != null && checkOut.isAfter(_endOfDay(to!))) {
        return false;
      }
      return true;
    }).toList();

    return Column(
      children: [
        /// FILTER BAR
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              _dateBox('From', from, (d) => setState(() => from = d)),
              const SizedBox(width: 8),
              _dateBox('To', to, (d) => setState(() => to = d)),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => setState(() {}),
              ),
              if (from != null || to != null)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() {
                    from = null;
                    to = null;
                  }),
                ),
            ],
          ),
        ),

        /// TABLE
        Expanded(
          child: filtered.isEmpty
              ? const Center(child: Text('No bills found'))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
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
                      final entry = filtered[i];
                      final int realIndex = entry.key;
                      final b = entry.value;

                      return DataRow(
                        key: ValueKey(realIndex),
                        cells: [
                          DataCell(Text('${i + 1}')),
                          DataCell(Text(b['invoiceNo'] ?? '')),
                          DataCell(Text(b['customerName'] ?? '')),
                          DataCell(Text(b['phone1'] ?? '')),
                          DataCell(Text(_fmt(b['checkInDate']))),
                          DataCell(Text(_fmt(b['checkOutDate']))),
                          DataCell(Text('₹${b['balance'] ?? 0}')),
                          DataCell(
                            Row(
                              children: [
                                /// VIEW
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  tooltip: 'View Bill',
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/bill_preview',
                                      arguments: b,
                                    );
                                  },
                                ),

                                /// DELETE
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: 'Delete',
                                  onPressed: () =>
                                      _confirmDelete(context, realIndex),
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
      ],
    );
  }

  /// DELETE CONFIRMATION
  Future<void> _confirmDelete(BuildContext context, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Bill'),
        content: const Text(
            'Are you sure you want to delete this bill? This action cannot be undone.'),
        actions: [
          TextButton(
            child: const Text('No'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text('Yes'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      context.read<BillHistoryStore>().deleteBill(index);
    }
  }

  /// DATE PICKER
  Widget _dateBox(
    String label,
    DateTime? value,
    Function(DateTime) onPick,
  ) {
    return OutlinedButton(
      child: Text(
        value == null ? label : DateFormat('dd/MM/yyyy').format(value),
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
    );
  }

  String _fmt(DateTime? d) =>
      d == null ? '' : DateFormat('dd/MM/yyyy').format(d);

  DateTime _startOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 0, 0, 0);

  DateTime _endOfDay(DateTime d) =>
      DateTime(d.year, d.month, d.day, 23, 59, 59);
}

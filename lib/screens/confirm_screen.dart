import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neyyar_heritage/history/confirm_store.dart';
import 'package:provider/provider.dart';

class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key});

  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen> {
  DateTime? from;
  DateTime? to;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<ConfirmStore>();

    if (store.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = store.confirmedQuotations.where((q) {
  final DateTime? checkInDate = q['checkInDate'];

  if (checkInDate == null) return false;

  /// From date filter
  if (from != null) {
    final fromDate = DateTime(
      from!.year,
      from!.month,
      from!.day,
    );

    if (checkInDate.isBefore(fromDate)) {
      return false;
    }
  }

  /// To date filter
  if (to != null) {
    final toDate = DateTime(
      to!.year,
      to!.month,
      to!.day,
      23,
      59,
      59,
    );

    if (checkInDate.isAfter(toDate)) {
      return false;
    }
  }

  return true;
}).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmed Quotations"),
      ),
      body: Column(
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
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() {
                    from = null;
                    to = null;
                  }),
                ),
              ],
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text("No Confirmed Quotations"))
                : SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('SI')),
                          DataColumn(label: Text('Advance')),
                          DataColumn(label: Text('Guest')),
                          DataColumn(label: Text('Phone')),
                          DataColumn(label: Text('Created On')),
                          DataColumn(label: Text('Package')),
                          DataColumn(label: Text('Check In')),
                          DataColumn(label: Text('Check Out')),
                          DataColumn(label: Text('Total Pax')), // 🔥 Added
                          DataColumn(label: Text('Actions')),
                        ],
                        rows: List.generate(filtered.length, (i) {
                          final q = filtered[i];

                          final DateTime? created = q['createdAt']; // 🔥 FIXED KEY

                          return DataRow(
                            cells: [
                              DataCell(Text('${i + 1}')),
                              DataCell(Text('${q['advance'] ?? 0}')), // 🔥 Added
                              DataCell(Text(q['customerName'] ?? '')),
                              DataCell(Text(q['phone1'] ?? '')),
                              DataCell(Text(
                                created != null
                                    ? DateFormat('dd/MM/yyyy').format(created)
                                    : '',
                              )),
                              DataCell(Text(q['package'] ?? '')),
                              DataCell(Text(
                                q['checkInDate'] != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(q['checkInDate'])
                                    : '',
                              )),
                              DataCell(Text(
                                q['checkOutDate'] != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(q['checkOutDate'])
                                    : '',
                              )),
                              DataCell(Text('${q['totalPax'] ?? 0}')), // 🔥 Added
                              DataCell(
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.visibility,
                                          color: Colors.green),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/quotation_preview_screen',
                                          arguments: q,
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.receipt_long,
                                          color: Colors.orange),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          '/bill_screen',
                                          arguments: q,
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
          ),
        ],
      ),
    );
  }

  Widget _dateBox(String label, DateTime? value, Function(DateTime) onPick) {
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
}

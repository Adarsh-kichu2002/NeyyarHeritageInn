import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../history/quotation_history_store.dart';

class QuotationHistoryTab extends StatefulWidget {
  const QuotationHistoryTab({super.key});

  @override
  State<QuotationHistoryTab> createState() => _QuotationHistoryTabState();
}

class _QuotationHistoryTabState extends State<QuotationHistoryTab> {
  DateTime? from;
  DateTime? to;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<QuotationHistoryStore>();

    if (store.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    /// APPLY DATE FILTER
    final filtered = store.quotations.where((q) {
      final DateTime? checkIn = q['checkInDate'] as DateTime?;
      if (checkIn == null) return false;

      if (from != null && checkIn.isBefore(_startOfDay(from!))) return false;
      if (to != null && checkIn.isAfter(_endOfDay(to!))) return false;

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
              ? const Center(child: Text('No quotations found'))
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('SI')),
                      DataColumn(label: Text('Guest')),
                      DataColumn(label: Text('Phone')),
                      DataColumn(label: Text('Package')),
                      DataColumn(label: Text('Check In')),
                      DataColumn(label: Text('Check Out')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: List.generate(filtered.length, (i) {
                      final q = filtered[i];
                      final String quotationId = q['id'];
                      final DateTime? checkIn = q['checkInDate'] as DateTime?;
                      final DateTime? checkOut = q['checkOutDate'] as DateTime?;

                      return DataRow(
                        key: ValueKey(quotationId),
                        cells: [
                          DataCell(Text('${i + 1}')),
                          DataCell(Text(q['customerName'] ?? '')),
                          DataCell(Text(q['phone1'] ?? '')),
                          DataCell(Text(q['package'] ?? '')),
                          DataCell(Text(
                              checkIn != null ? DateFormat('dd/MM/yyyy').format(checkIn) : '')),
                          DataCell(Text(
                              checkOut != null ? DateFormat('dd/MM/yyyy').format(checkOut) : '')),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.visibility),
                                  tooltip: 'View',
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/quotation_preview_screen',
                                      arguments: q,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Edit',
                                  onPressed: () {
                                    Navigator.pushNamed(
                                      context,
                                      '/create_quotation',
                                      arguments: {
                                        ...q,
                                        'quotationId': quotationId,
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  tooltip: 'Delete',
                                  onPressed: () {
                                    _confirmDelete(context, quotationId);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.receipt_long),
                                  tooltip: 'Generate Bill',
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
      ],
    );
  }

  /// DATE PICKER
  Widget _dateBox(String label, DateTime? value, Function(DateTime) onPick) {
    return OutlinedButton(
      child: Text(value == null ? label : DateFormat('dd/MM/yyyy').format(value)),
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

  /// CONFIRM DELETE
  Future<void> _confirmDelete(BuildContext context, String quotationId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Quotation'),
        content: const Text(
            'Are you sure you want to delete this quotation?\nThis action cannot be undone.'),
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

    if (confirmed == true && context.mounted) {
      await context.read<QuotationHistoryStore>().deleteQuotation(quotationId);
    }
  }

  /// DATE HELPERS
  DateTime _startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _endOfDay(DateTime d) => DateTime(d.year, d.month, d.day, 23, 59, 59);
}

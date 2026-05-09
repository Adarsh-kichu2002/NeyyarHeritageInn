import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text('Bills'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,

        /// DOWNLOAD BUTTON
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),

            onSelected: _handleDownloadSelection,

            itemBuilder: (context) => const [
              PopupMenuItem(
                value: '7days',
                child: Text('Last 7 Days'),
              ),
              PopupMenuItem(
                value: '1month',
                child: Text('1 Month'),
              ),
              PopupMenuItem(
                value: 'currentMonth',
                child: Text('Current Month'),
              ),
              PopupMenuItem(
                value: 'custom',
                child: Text('Custom'),
              ),
            ],
          ),
        ],
      ),

      body: store.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                /// FILTER
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(8),

                  child: Row(
                    children: [
                      _dateBox(
                        'From',
                        from,
                        (d) => setState(() => from = d),
                      ),

                      const SizedBox(width: 8),

                      _dateBox(
                        'To',
                        to,
                        (d) => setState(() => to = d),
                      ),

                      IconButton(
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          setState(() {});
                        },
                      ),

                      if (from != null || to != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
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

                Expanded(
                  child: _buildTable(store),
                ),
              ],
            ),
    );
  }

  /// DOWNLOAD MENU
  Future<void> _handleDownloadSelection(String value) async {
    DateTime start;
    DateTime end;

    final now = DateTime.now();

    if (value == '7days') {
      start = now.subtract(const Duration(days: 7));
      end = now;
    } else if (value == '1month') {
      start = DateTime(now.year, now.month - 1, now.day);
      end = now;
    } else if (value == 'currentMonth') {
      start = DateTime(now.year, now.month, 1);
      end = now;
    } else {
      final result = await _showCustomDialog();

      if (result == null) return;

      final month = result['month']!;
      final year = result['year']!;

      start = DateTime(year, month, 1);
      end = DateTime(
        year,
        month + 1,
        0,
        23,
        59,
        59,
      );
    }

    await _downloadBillsPdf(start, end);
  }

  /// CUSTOM MONTH/YEAR POPUP
  Future<Map<String, int>?> _showCustomDialog() async {
    final monthCtrl = TextEditingController();
    final yearCtrl = TextEditingController();

    return showDialog<Map<String, int>>(
      context: context,

      builder: (_) {
        return AlertDialog(
          title: const Text('Enter Month & Year'),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              TextField(
                controller: monthCtrl,
                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  labelText: 'Month',
                ),
              ),

              TextField(
                controller: yearCtrl,
                keyboardType: TextInputType.number,

                decoration: const InputDecoration(
                  labelText: 'Year',
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  {
                    'month': int.parse(monthCtrl.text),
                    'year': int.parse(yearCtrl.text),
                  },
                );
              },
              child: const Text('Download'),
            ),
          ],
        );
      },
    );
  }

  /// PDF DOWNLOAD
  Future<void> _downloadBillsPdf(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final store = context.read<BillHistoryStore>();

    final bills = store.bills.where((bill) {
      final DateTime? checkOut =
          bill['checkOutDate'];

      if (checkOut == null) {
        return false;
      }

      return !checkOut.isBefore(startDate) &&
          !checkOut.isAfter(endDate);
    }).toList();

    if (bills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No bills found',
          ),
        ),
      );

      return;
    }

    final fontRegular = pw.Font.ttf(
      await rootBundle.load(
        'assets/fonts/Roboto-Regular.ttf',
      ),
    );

    final fontBold = pw.Font.ttf(
      await rootBundle.load(
        'assets/fonts/Roboto-Bold.ttf',
      ),
    );

    final pdf = pw.Document();

    for (final bill in bills) {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,

          theme: pw.ThemeData.withFont(
            base: fontRegular,
            bold: fontBold,
          ),

          build: (_) {
            return [
              pw.Text(
                'Invoice: ${bill['invoiceNo']}',
                style: pw.TextStyle(
                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 10),

              pw.Text(
                'Guest: ${bill['customerName']}',
              ),

              pw.Text(
                'Phone: ${bill['phone1']}',
              ),

              pw.Text(
                'Check In: ${_fmt(bill['checkInDate'])}',
              ),

              pw.Text(
                'Check Out: ${_fmt(bill['checkOutDate'])}',
              ),

              pw.Divider(),

              pw.Text(
                'Balance: ₹${bill['balance']}',
                style: pw.TextStyle(
                  fontWeight:
                      pw.FontWeight.bold,
                ),
              ),
            ];
          },
        ),
      );
    }

    await Printing.layoutPdf(
      onLayout: (_) async {
        return pdf.save();
      },
    );
  }

  Widget _buildTable(
    BillHistoryStore store,
  ) {
    final filtered =
        store.bills.where((bill) {
      final DateTime? checkOut =
          bill['checkOutDate'];

      if (from == null &&
          to == null) {
        return true;
      }

      if (checkOut == null) {
        return false;
      }

      if (from != null &&
          checkOut.isBefore(
            _startOfDay(from!),
          )) {
        return false;
      }

      if (to != null &&
          checkOut.isAfter(
            _endOfDay(to!),
          )) {
        return false;
      }

      return true;
    }).toList();

    /// SORT DESCENDING
    filtered.sort(
      (a, b) {
        final DateTime? dateA =
            a['checkOutDate'];

        final DateTime? dateB =
            b['checkOutDate'];

        if (dateA == null &&
            dateB == null) {
          return 0;
        }

        if (dateA == null) {
          return 1;
        }

        if (dateB == null) {
          return -1;
        }

        return dateB.compareTo(
          dateA,
        );
      },
    );

    if (filtered.isEmpty) {
      return const Center(
        child: Text(
          'No bills found',
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection:
          Axis.vertical,

      child:
          SingleChildScrollView(
        scrollDirection:
            Axis.horizontal,

        child: DataTable(
          headingRowColor:
              MaterialStateProperty.all(
            Colors.grey.shade200,
          ),

          columns: const [
            DataColumn(
              label: Text('SI'),
            ),
            DataColumn(
              label:
                  Text('Invoice'),
            ),
            DataColumn(
              label:
                  Text('Guest'),
            ),
            DataColumn(
              label:
                  Text('Phone'),
            ),
            DataColumn(
              label:
                  Text('Check In'),
            ),
            DataColumn(
              label:
                  Text('Check Out'),
            ),
            DataColumn(
              label:
                  Text('Total'),
            ),
            DataColumn(
              label:
                  Text('Actions'),
            ),
          ],

          rows:
              List.generate(
            filtered.length,
            (i) {
              final b =
                  filtered[i];

              final hasPayment =
                  b['payment'] !=
                      null;

              return DataRow(
                color:
                    MaterialStateProperty.resolveWith(
                  (_) {
                    if (hasPayment) {
                      return const Color.fromARGB(
                        255,
                        245,
                        221,
                        8,
                      );
                    }

                    return Colors
                        .white;
                  },
                ),

                cells: [
                  DataCell(
                    Text(
                      '${i + 1}',
                    ),
                  ),

                  DataCell(
                    Text(
                      '${b['invoiceNo']}',
                    ),
                  ),

                  DataCell(
                    Text(
                      b['customerName'] ??
                          '',
                    ),
                  ),

                  DataCell(
                    Text(
                      '${b['phone1']}',
                    ),
                  ),

                  DataCell(
                    Text(
                      _fmt(
                        b['checkInDate'],
                      ),
                    ),
                  ),

                  DataCell(
                    Text(
                      _fmt(
                        b['checkOutDate'],
                      ),
                    ),
                  ),

                  DataCell(
                    Text(
                      '₹${b['balance']}',
                    ),
                  ),

                  DataCell(
                    Row(
                      children: [
                        /// VIEW
                        IconButton(
                          icon:
                              const Icon(
                            Icons
                                .visibility,
                            color: Colors
                                .green,
                          ),
                          onPressed:
                              () {
                            Navigator.pushNamed(
                              context,
                              '/bill_preview',
                              arguments:
                                  b,
                            );
                          },
                        ),

                        /// EDIT DISABLED AFTER PAYMENT
                        IconButton(
                          icon:
                              Icon(
                            Icons
                                .edit,
                            color: hasPayment
                                ? Colors.grey
                                : Colors.blue,
                          ),

                          onPressed:
                              hasPayment
                                  ? null
                                  : () {
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

                        /// PAYMENT
                        IconButton(
                          icon:
                              const Icon(
                            Icons
                                .currency_rupee,
                            color: Colors
                                .purple,
                          ),

                          onPressed:
                              () {
                            Navigator.pushNamed(
                              context,
                              '/payment_screen',
                              arguments: {
                                ...b,
                                'isReadOnlyPayment':
                                    true,
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _dateBox(
    String label,
    DateTime? value,
    Function(DateTime)
        onPick,
  ) {
    return OutlinedButton(
      onPressed: () async {
        final d =
            await showDatePicker(
          context: context,
          firstDate:
              DateTime(2020),
          lastDate:
              DateTime(2100),
          initialDate:
              value ??
                  DateTime.now(),
        );

        if (d != null) {
          onPick(d);
        }
      },

      child: Text(
        value == null
            ? label
            : DateFormat(
                'dd/MM/yyyy',
              ).format(
                value,
              ),
      ),
    );
  }

  String _fmt(
    DateTime? d,
  ) {
    if (d == null) {
      return '';
    }

    return DateFormat(
      'dd/MM/yyyy',
    ).format(d);
  }

  DateTime _startOfDay(
    DateTime d,
  ) {
    return DateTime(
      d.year,
      d.month,
      d.day,
    );
  }

  DateTime _endOfDay(
    DateTime d,
  ) {
    return DateTime(
      d.year,
      d.month,
      d.day,
      23,
      59,
      59,
    );
  }
}

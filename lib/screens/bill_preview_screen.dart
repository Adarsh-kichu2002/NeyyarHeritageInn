import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../history/bill_history_store.dart';

class BillPreviewScreen extends StatelessWidget {
  const BillPreviewScreen({super.key});

  Color get green => const Color.fromARGB(255, 52, 191, 59);

  int _toInt(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;

  String _fmtDate(dynamic d) {
    if (d == null) return '';
    if (d is DateTime) {
      return DateFormat('dd/MM/yyyy').format(d);
    }
    if (d is String) {
      final parsed = DateTime.tryParse(d);
      if (parsed != null) {
        return DateFormat('dd/MM/yyyy').format(parsed);
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! Map<String, dynamic>) {
      return const Scaffold(
        body: Center(child: Text('No bill data available')),
      );
    }

    final Map<String, dynamic> data = args;

    return Scaffold(
      appBar: AppBar(title: const Text('Bill Preview')),
      bottomNavigationBar: _actions(context, data),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _header(data),
            const SizedBox(height: 12),
            _receiptTitle(),
            const SizedBox(height: 12),
            _partyInfo(data),
            const SizedBox(height: 16),
            _itemsTable(data),
            const SizedBox(height: 16),
            _summaryWithNotes(data),
            const SizedBox(height: 16),
            _footer(),
          ],
        ),
      ),
    );
  }

  Widget _header(Map<String, dynamic> data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Image.asset(
            'assets/images/neyyar_logo.png',
            height: 90,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Invoice: ${data['invoiceNo'] ?? ''}',
                style: TextStyle(color: green, fontWeight: FontWeight.bold),
              ),
              Text(
                'Date: ${_fmtDate(data['checkOutDate'])}',
                style: TextStyle(color: green),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _receiptTitle() {
    return Text(
      'RECEIPT',
      style: TextStyle(color: green, fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _partyInfo(Map<String, dynamic> data) {
    return Row(
      children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(data['customerName'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Mob: ${data['phone1'] ?? ''}'),
          ]),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('Check In: ${_fmtDate(data['checkInDate'])}'),
            Text('Check Out: ${_fmtDate(data['checkOutDate'])}'),
          ]),
        ),
      ],
    );
  }

  Widget _itemsTable(Map<String, dynamic> data) {
    final List items = data['items'] ?? [];

    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(2),
        3: FlexColumnWidth(2),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: green),
          children: const [
            _HeaderCell('Description'),
            _HeaderCell('Price'),
            _HeaderCell('Qty'),
            _HeaderCell('Total'),
          ],
        ),
        ...items.map((i) {
          final qty = _toInt(i['qty']);
          final price = _toInt(i['price']);
          return TableRow(
            children: [
              _Cell(i['name'] ?? ''),
              _Cell('₹$price'),
              _Cell('$qty'),
              _Cell('₹${qty * price}'),
            ],
          );
        }),
      ],
    );
  }

  Widget _summaryWithNotes(Map<String, dynamic> data) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          flex: 3,
          child: Text(
            'Thank you for choosing us.\n'
            'We look forward to hosting you again.\n'
            'Best Regards,\nNeyyar Heritage Inn.',
          ),
        ),
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _totalRow('Total', _toInt(data['subtotal'])),
              _totalRow('GST (5%)', _toInt(data['gst'])),
              _totalRow('Advance', _toInt(data['advance'])),
              const Divider(),
              _totalRow('Balance', _toInt(data['balance']), bold: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _totalRow(String label, int value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
        Text('₹$value',
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
      ],
    );
  }

  Widget _footer() {
    return Container(
      color: green,
      padding: const EdgeInsets.all(8),
      child: const Row(
        children: [
          Expanded(child: Text('9656763391', style: TextStyle(color: Colors.white))),
          Expanded(
              child: Text('neyyarheritageinn@gmail.com',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white))),
          Expanded(
              child: Text('www.neyyarheritage.in',
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _actions(BuildContext context, Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              onPressed: data['_saved'] == true
                  ? null
                  : () async {
                      data['_saved'] = true;
                      await context.read<BillHistoryStore>().addBill(data);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bill saved')),
                      );
                    },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.download),
              label: const Text('Download'),
              onPressed: () => _downloadPdf(data),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPdf(Map<String, dynamic> data) async {
    final font =
        pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));

    final logo = (await rootBundle.load('assets/images/neyyar_logo.png'))
        .buffer
        .asUint8List();

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        theme: pw.ThemeData.withFont(base: font),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Image(pw.MemoryImage(logo), height: 80),
            pw.Text('Invoice: ${data['invoiceNo']}'),
            pw.Text('Date: ${_fmtDate(data['checkOutDate'])}'),
            pw.SizedBox(height: 12),
            ...data['items'].map<pw.Widget>((i) {
              final qty = _toInt(i['qty']);
              final price = _toInt(i['price']);
              return pw.Text('${i['name']} — ₹$price x $qty');
            }),
          ],
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (_) => pdf.save());
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child:
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}

class _Cell extends StatelessWidget {
  final String text;
  const _Cell(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(8), child: Text(text));
  }
}

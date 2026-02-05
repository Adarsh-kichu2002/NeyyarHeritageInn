// quotation_preview_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neyyar_heritage/history/quotation_history_store.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class QuotationPreviewScreen extends StatefulWidget {
  const QuotationPreviewScreen({super.key});

  @override
  State<QuotationPreviewScreen> createState() => _QuotationPreviewScreenState();
}

class _QuotationPreviewScreenState extends State<QuotationPreviewScreen> {
  late Map<String, dynamic> data;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! Map<String, dynamic>) {
      data = {};
    } else {
      data = args;
    }
  }

  String _date(dynamic d) {
    if (d == null) return '';
    if (d is DateTime) return DateFormat('MMM dd, yyyy').format(d);
    return d.toString();
  }

  String _time(dynamic t) {
    if (t == null) return '';
    if (t is TimeOfDay) return t.format(context);
    return t.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No quotation data found',
            style: TextStyle(fontSize: 16, color: Colors.red),
          ),
        ),
      );
    }

    final rooms = data['rooms'] as List? ?? [];
    final facilities = data['facilities'] as List? ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Quotation Preview')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Image.asset('assets/images/neyyar_logo.png', height: 60),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'QUOTATION',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text('Date : ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            /// CUSTOMER DETAILS
            const Text('To,'),
            Text(data['customerName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Mob: ${data['phone1'] ?? ''}'),
            if (data['phone2'] != null && data['phone2'].toString().isNotEmpty)
              Text('Alt Mob: ${data['phone2']}'),
            if (data['address'] != null && data['address'].toString().isNotEmpty)
              Text(data['address']),

            const SizedBox(height: 16),

            /// DESCRIPTION
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  const TextSpan(text: 'We appreciate your interest in '),
                  const TextSpan(
                    text: 'Neyyar Heritage Inn - Home Stay',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: ' for your upcoming '),
                  TextSpan(
                    text: data['package'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        ' (Check In: ${_date(data['checkInDate'])} ${_time(data['checkInTime'])}, '
                        'Check Out: ${_date(data['checkOutDate'])} ${_time(data['checkOutTime'])}).',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(text: '\n\nAt '),
                  const TextSpan(
                    text: 'Neyyar Heritage Inn - Home Stay, ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const TextSpan(
                    text:
                        'with exceptional experiences that create lasting memories. We encourage you '
                        'to review the details and feel free to reach out if you have any questions.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            /// TABLE HEADER
            _greenHeader(),

            ...rooms.where((r) => r['selected'] == true).map(
                  (r) => _row(r['name'], r['qty'].toString(), r['price'], r['price'] * r['qty']),
                ),

            const SizedBox(height: 16),

            if ((data['extraTotal'] ?? 0) > 0)
              Text(
                  'Extra Persons (${data['extraPersons']} x ${data['extraPersonPrice']}) ₹${data['extraTotal']}'),

            if ((data['discount'] ?? 0) > 0)
              Text('Discount  -₹${data['discount']}', style: const TextStyle(color: Colors.red)),

            const SizedBox(height: 16),

            /// PAX
            Text(
              'Pax -- ${data['adult'] ?? 0}+${data['children'] ?? 0}+${data['child'] ?? 0} = ${data['totalPax'] ?? 0}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            /// FACILITIES
            const Text('Facilities', style: TextStyle(fontWeight: FontWeight.bold)),
            ...facilities.map((f) => Text('• $f')),

            const Divider(),
            const SizedBox(height: 16),

            /// TOTAL
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: ₹${data['total'] ?? 0}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 24),

            /// FOOTER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.green,
              child: const Column(
                children: [
                  Text('+91 9656763391 | homestay.neyyar@gmail.com', style: TextStyle(color: Colors.white)),
                  Text('www.neyyarheritage.in', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// SAVE
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                onPressed: () async {
                  final store = context.read<QuotationHistoryStore>();

                  String? timeToString(dynamic t) {
                    if (t == null) return null;
                    if (t is TimeOfDay) return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                    return t.toString();
                  }

                  final Map<String, dynamic> finalData = {
                    ...data,
                    'checkInTime': timeToString(data['checkInTime']),
                    'checkOutTime': timeToString(data['checkOutTime']),
                    'savedAt': DateTime.now(),
                  };

                  /// UPDATE (EDIT MODE)
                  if (data.containsKey('quotationId')) {
                    await store.updateQuotation(data['quotationId'], finalData);
                  }
                  /// ADD (NEW QUOTATION)
                  else {
                    await store.addQuotation(finalData);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Quotation saved successfully')),
                  );

                  Navigator.pop(context);
                },
              ),
            ),

            /// DOWNLOAD PDF
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Download PDF'),
                onPressed: _downloadPdf,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// PDF GENERATION
  Future<void> _downloadPdf() async {
  final pdf = pw.Document();

  /// Load Unicode font (₹, • supported)
  final pw.Font font = pw.Font.ttf(await rootBundle.load('assets/fonts/Roboto-Regular.ttf'));

  /// Load logo
  final ByteData logoData = await rootBundle.load('assets/images/neyyar_logo.png');
  final Uint8List logoBytes = logoData.buffer.asUint8List();

  final List rooms = data['rooms'] as List? ?? [];
  final List facilities = data['facilities'] as List? ?? [];

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      theme: pw.ThemeData.withFont(base: font, bold: font),
      build: (context) => [
        /// HEADER
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Image(pw.MemoryImage(logoBytes), height: 60),
            pw.Spacer(),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'QUOTATION',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.green700,
                  ),
                ),
                pw.Text('Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}'),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 16),
        pw.Divider(),

        /// CUSTOMER DETAILS
        pw.Text('To,'),
        pw.Text(data['customerName'] ?? '', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text('Mob: ${data['phone1'] ?? ''}'),
        if (data['phone2'] != null && data['phone2'].toString().isNotEmpty)
          pw.Text('Alt Mob: ${data['phone2']}'),
        if (data['address'] != null && data['address'].toString().isNotEmpty)
          pw.Text(data['address']),

        pw.SizedBox(height: 16),

        /// DESCRIPTION
        pw.RichText(
          text: pw.TextSpan(
            style: const pw.TextStyle(fontSize: 11),
            children: [
              const pw.TextSpan(text: 'We appreciate your interest in '),
              pw.TextSpan(
                text: 'Neyyar Heritage Inn - Home Stay',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              const pw.TextSpan(text: ' for your upcoming '),
              pw.TextSpan(
                text: data['package'] ?? '',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(
                text:
                    ' (Check In: ${_date(data['checkInDate'])} ${_time(data['checkInTime'])}, '
                    'Check Out: ${_date(data['checkOutDate'])} ${_time(data['checkOutTime'])}).',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              const pw.TextSpan(text: '\n\nAt '),
              pw.TextSpan(
                text: 'Neyyar Heritage Inn - Home Stay, ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              const pw.TextSpan(
                  text:
                      'we are committed to providing our guests with exceptional experiences '
                      'that create lasting memories. Please review the quotation and feel free '
                      'to contact us for any clarification.'),
            ],
          ),
        ),

        pw.SizedBox(height: 20),

        /// TABLE HEADER
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.green700,
            borderRadius: pw.BorderRadius.circular(6),
          ),
          child: pw.Row(
            children: [
              pw.Expanded(flex: 3, child: _whiteText('Item Description')),
              pw.Expanded(child: _whiteText('Qty')),
              pw.Expanded(child: _whiteText('Price')),
              pw.Expanded(child: _whiteText('Total')),
            ],
          ),
        ),

        /// ROOM ROWS
        ...rooms.where((r) => r['selected'] == true).map(
              (r) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 6),
                child: pw.Row(
                  children: [
                    pw.Expanded(flex: 3, child: pw.Text(r['name'] ?? '')),
                    pw.Expanded(child: pw.Text('${r['qty'] ?? 0}')),
                    pw.Expanded(child: pw.Text('₹${r['price'] ?? 0}')),
                    pw.Expanded(
                        child: pw.Text('₹${(r['price'] ?? 0) * (r['qty'] ?? 0)}')),
                  ],
                ),
              ),
            ),

        pw.SizedBox(height: 8),

        /// EXTRA PERSONS
        if ((data['extraTotal'] ?? 0) > 0)
          pw.Text(
            'Extra Persons (${data['extraPersons'] ?? 0} x ${data['extraPersonPrice'] ?? 0}) '
            '₹${data['extraTotal']}',
          ),

        /// DISCOUNT
        if ((data['discount'] ?? 0) > 0)
          pw.Text(
            'Discount - ₹${data['discount']}',
            style: const pw.TextStyle(color: PdfColors.red),
          ),

        pw.SizedBox(height: 12),

        /// PAX
        pw.Text(
          'Pax -- ${data['adult'] ?? 0}+${data['children'] ?? 0}+${data['child'] ?? 0} = ${data['totalPax'] ?? 0}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),

        pw.SizedBox(height: 12),

        /// FACILITIES
        pw.Text('Facilities', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ...facilities.map((f) => pw.Text('• $f')),

        pw.Divider(),

        /// TOTAL
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Total: ₹${data['total'] ?? 0}',
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
        ),

        pw.SizedBox(height: 20),

        /// FOOTER
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(10),
          color: PdfColors.green700,
          child: pw.Column(
            children: [
              pw.Text('+91 9656763391 | homestay.neyyar@gmail.com',
                  style: const pw.TextStyle(color: PdfColors.white)),
              pw.Text('www.neyyarheritage.in',
                  style: const pw.TextStyle(color: PdfColors.white)),
            ],
          ),
        ),
      ],
    ),
  );

  /// SAVE FILE
  final Directory dir = await getApplicationDocumentsDirectory();
  final File file = File(
      '${dir.path}/Quotation_${DateTime.now().millisecondsSinceEpoch}.pdf');
  await file.writeAsBytes(await pdf.save());

  /// SHARE
  await Share.shareXFiles([XFile(file.path)],
      text: 'Quotation - Neyyar Heritage Inn');
}

/// HELPER
pw.Text _whiteText(String text) {
  return pw.Text(
    text,
    style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold),
  );
}

  /// WIDGETS
  Widget _greenHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Expanded(flex: 3, child: Text('Item Description', style: TextStyle(color: Colors.white))),
          Expanded(child: Text('Qty', style: TextStyle(color: Colors.white))),
          Expanded(child: Text('Price', style: TextStyle(color: Colors.white))),
          Expanded(child: Text('Total', style: TextStyle(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _row(String item, String qty, int price, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text(item)),
          Expanded(child: Text(qty)),
          Expanded(child: Text(price.toString())),
          Expanded(child: Text(total.toString())),
        ],
      ),
    );
  }
}

/// BULLET POINT
class Bullet extends StatelessWidget {
  final String text;
  final Color color;
  const Bullet(this.text, {this.color = Colors.black, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• ', style: TextStyle(color: color)),
        Expanded(child: Text(text, style: TextStyle(color: color))),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neyyar_heritage/history/quotation_history_store.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';


class QuotationPreviewScreen extends StatefulWidget {
  const QuotationPreviewScreen({super.key});

  @override
  State<QuotationPreviewScreen> createState() =>
      _QuotationPreviewScreenState();
}

class _QuotationPreviewScreenState
    extends State<QuotationPreviewScreen> {
  late Map<String, dynamic> data;

@override
void didChangeDependencies() {
  super.didChangeDependencies();

  final args = ModalRoute.of(context)?.settings.arguments;

  if (args == null || args is! Map<String, dynamic>) {
    // Fail-safe: redirect back or show error UI
    data = {};
  } else {
    data = args;
  }
}

  String _date(DateTime? d) =>
      d == null ? '' : DateFormat('MMM dd, yyyy').format(d);

  String _time(TimeOfDay? t) =>
      t == null ? '' : t.format(context);


  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> extractedData =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>? ?? {};
    
    if (extractedData.isEmpty) {
  return const Scaffold(
    body: Center(
      child: Text(
        'No quotation data found',
        style: TextStyle(fontSize: 16, color: Colors.red),
      ),
    ),
  );
}

    final rooms = extractedData['rooms'] as List;
    final facilities = extractedData['facilities'] as List;
    data = extractedData;
    

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
                Image.asset(
                  'assets/images/neyyar_logo.png',
                  height: 60,
                ),
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
                    Text(
                      'Date : ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                    ),
                  ],
                )
              ],
            ),

            const SizedBox(height: 20),

            /// CUSTOMER DETAILS
            const Text('To,'),
            Text(
              extractedData['customerName'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Mob: ${extractedData['phone1']}'),
            if (extractedData['phone2'].toString().isNotEmpty)
              Text('Alt Mob: ${extractedData['phone2']}'),
            if (extractedData['address'].toString().isNotEmpty)
              Text(extractedData['address']),

            const SizedBox(height: 16),

            /// DESCRIPTION
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                   const TextSpan(
        text: 'We appreciate your interest in ',
      ),
      const TextSpan(
        text: 'Neyyar Heritage Inn - Home Stay',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const TextSpan(
        text: ' for your upcoming ',
      ),
                  TextSpan(
                    text: extractedData['package'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        ' (Check In: ${_date(extractedData['checkInDate'])} ${_time(extractedData['checkInTime'])}, '
                        'Check Out: ${_date(extractedData['checkOutDate'])} ${_time(extractedData['checkOutTime'])}).',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                 const TextSpan(
        text:'\n\nAt' 
            ),
            const TextSpan(
              text: ' Neyyar Heritage Inn - Home Stay, ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const TextSpan(
              text:
            'with exceptional experiences that create lasting memories. We encourage you '
            'to review the details and feel free to reach out if you have any questions or '
            'require further clarification.',
      ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// TABLE HEADER
            _greenHeader(),

            ...rooms
    .where((r) => r['selected'])
    .map(
      (r) => _row(
        r['name'],
        r['qty'].toString(),
        r['price'],
        r['price'] * r['qty'],
      ),
    ),

            const SizedBox(height: 16),

            
          if (extractedData['extraTotal'] > 0)
            Text(
                'Extra Persons (${extractedData['extraPersons']} x ${extractedData['extraPersonPrice']}) ₹${extractedData['extraTotal']}'),

          if (extractedData['discount'] > 0)
            Text('Discount  -₹${extractedData['discount']}',
                style: const TextStyle(color: Colors.red)),

          const SizedBox(height: 16),


              /// PAX
            Text(
              'Pax -- ${extractedData['adult']}+${extractedData['children']}+${extractedData['child']} = ${extractedData['totalPax']}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

              /// FACILITIES
              const Text('Facilities',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...facilities.map((f) => Text('• $f')),

          const Divider(),


              const SizedBox(height: 16),

              /// TOTAL
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Total: ₹${extractedData['total']}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// TERMS
              const Divider(),
              const Text(
                'Terms and Conditions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Bullet('All rates quoted are valid for 15 days.'),
              const Bullet(
                  '50% advance payment is required to confirm booking. Reservations will be allotted and confirmed on a first-come, first-served basis subject to receipt of advance payment.'),
              const Bullet(
                  'The remaining 50% is to be paid upon check-in.'),
              const Bullet('Food Usage : Outside food is strictly not permitted inside property.'),
              const Bullet(
                'No transportation available.',
                color: Colors.red,
              ),
              const Bullet(
                'If there is less than the number of members mentioned in the booking confirmation, it should be informed 2 days in advance. Otherwise the full amount will have to be paid.',
                color: Colors.red,
              ),
              const Bullet(
                'Cancellation made 72 hours prior to the arrival date will receive a full refund of the advance.',
                color: Colors.red,
              ),
              const Bullet(
                'Cancellation made within 72 hours of the arrival date will result in forfeiture of the advance.',
                color: Colors.red,
              ),

              const SizedBox(height: 24),

              /// FOOTER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                color: Colors.green,
                child: const Column(
                  children: [
                    Text(
                      '+91 9656763391 | homestay.neyyar@gmail.com',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'www.neyyarheritage.in',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // SAVE
SizedBox(
  width: double.infinity,
  child: ElevatedButton.icon(
    icon: const Icon(Icons.save),
    label: const Text('Save'),
    onPressed: () {
      final store = context.read<QuotationHistoryStore>();

      /// BUILD FINAL DATA
      final Map<String, dynamic> finalData = {
        ...data,
        'savedAt': DateTime.now(),
      };

      /// UPDATE (EDIT MODE)
      if (data.containsKey('historyIndex')) {
        store.updateQuotation(
          data['historyIndex'],
          finalData,
        );
      }
      /// ADD (NEW QUOTATION)
      else {
        store.addQuotation(finalData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Quotation saved successfully'),
        ),
      );

      /// RETURN TO HISTORY (IMPORTANT)
      Navigator.pop(context);
    },
  ),
),

              /// DOWNLOAD
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
    // DOWNLOAD PDF
 Future<void> _downloadPdf() async {
  final pdf = pw.Document();


  /// Load Unicode font (₹, • supported)
  final pw.Font font = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
  );

  /// Load logo
  final ByteData logoData =
      await rootBundle.load('assets/images/neyyar_logo.png');
  final Uint8List logoBytes = logoData.buffer.asUint8List();

  final List rooms = data['rooms'] as List;
  final List facilities = data['facilities'] as List;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(24),
      theme: pw.ThemeData.withFont(
        base: font,
        bold: font,
      ),
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
                pw.Text(
                  'Date: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                ),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 16),
        pw.Divider(),

        /// CUSTOMER DETAILS
        pw.Text('To,'),
        pw.Text(
          data['customerName'],
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('Mob: ${data['phone1']}'),
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
                text: data['package'],
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
                    'to contact us for any clarification.',
              ),
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
                    pw.Expanded(flex: 3, child: pw.Text(r['name'])),
                    pw.Expanded(child: pw.Text('${r['qty']}')),
                    pw.Expanded(child: pw.Text('₹${r['price']}')),
                    pw.Expanded(
                        child: pw.Text('₹${r['price'] * r['qty']}')),
                  ],
                ),
              ),
            ),

        pw.Divider(),

        if (data['extraTotal'] > 0)
          pw.Text(
            'Extra Persons (${data['extraPersons']} x ${data['extraPersonPrice']}) '
            '₹${data['extraTotal']}',
          ),

        if (data['discount'] > 0)
          pw.Text(
            'Discount - ₹${data['discount']}',
            style: const pw.TextStyle(color: PdfColors.red),
          ),

        pw.SizedBox(height: 12),

        pw.Text(
          'Pax -- ${data['adult']}+${data['children']}+${data['child']} = ${data['totalPax']}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),

        pw.SizedBox(height: 12),

        pw.Text('Facilities',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ...facilities.map((f) => pw.Text('• $f')),

        pw.Divider(),

        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Total: ₹${data['total']}',
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
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
              pw.Text(
                '+91 9656763391 | homestay.neyyar@gmail.com',
                style: const pw.TextStyle(color: PdfColors.white),
              ),
              pw.Text(
                'www.neyyarheritage.in',
                style: const pw.TextStyle(color: PdfColors.white),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  /// SAVE FILE (ANDROID + iOS)
  final Directory dir = await getApplicationDocumentsDirectory();
  final File file = File(
    '${dir.path}/Quotation_${DateTime.now().millisecondsSinceEpoch}.pdf',
  );

  await file.writeAsBytes(await pdf.save());

  /// SHARE
  await Share.shareXFiles(
    [XFile(file.path)],
    text: 'Quotation - Neyyar Heritage Inn',
  );
}

/// HELPERS
pw.Text _whiteText(String text) {
  return pw.Text(
    text,
    style: pw.TextStyle(
      color: PdfColors.white,
      fontWeight: pw.FontWeight.bold,
    ),
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

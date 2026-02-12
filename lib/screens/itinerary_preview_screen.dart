import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:typed_data';

class ItineraryPreviewScreen extends StatelessWidget {
  const ItineraryPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String? docId = args['docId'];
    final String mode = args['mode'] ?? 'create';

    final DateTime date = args['date'];
    final String start = args['start'];
    final String end = args['end'];

    final groupedItems = _groupByTime(args['items']);

    return Scaffold(
      appBar: AppBar(title: const Text('Itinerary Preview')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/neyyar_logo.png',
                        height: 70,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${args['package']} ITINERARY'.toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${DateFormat('dd-MMM-yyyy').format(date)} '
                              '(${_to12Hr(start)} – ${_to12Hr(end)})',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// ADDRESS
                  const Text('To,'),
                  Text(args['name']),
                  Text('Mob: ${args['mobile']}'),

                  const SizedBox(height: 16),

                  /// INTRO
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(text: 'At '),
                        TextSpan(
                          text: 'Neyyar Heritage Inn - Home Stay ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text:
                              'we are committed to providing our guests with exceptional experiences.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// PAX
                  Text(
                    'No. of Pax: '
                    '${args['adult']} + ${args['children']} + ${args['child']} '
                    '= ${args['adult'] + args['children'] + args['child']}',
                  ),

                  const SizedBox(height: 16),

                  /// TABLE
                  _buildTable(groupedItems),

                  const SizedBox(height: 20),

                  /// TERMS
                  const Text(
                    'Terms & Conditions',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '• No transportation available.\n'
                    '• If members are less than confirmed, inform 3 days in advance.\n'
                    '• Management reserves the right to reschedule.',
                    style: TextStyle(color: Colors.red),
                  ),

                  const SizedBox(height: 20),

                  const Text('We look forward to welcoming you.'),
                  const SizedBox(height: 12),
                  const Text('Thanks'),
                  const SizedBox(height: 12),
                  const Text('With regards,'),
                  const Text(
                    'Neyyar Heritage Inn',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          /// FOOTER BAR
          Container(
            color: const Color.fromRGBO(52, 191, 59, 1),
            padding: const EdgeInsets.all(8),
            child: const Row(
              children: [
                Expanded(
                  child: Text('9656763391',
                      style: TextStyle(color: Colors.white)),
                ),
                Expanded(
                  child: Text(
                    'neyyarheritageinn@gmail.com',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Expanded(
                  child: Text(
                    'www.neyyarheritage.in',
                    textAlign: TextAlign.end,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          /// SAVE & PRINT
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton(
              onPressed: () async {
                final firestoreData = {
                  'package': args['package'],
                  'name': args['name'],
                  'mobile': args['mobile'],
                  'date': Timestamp.fromDate(date),
                  'start': start,
                  'end': end,
                  'adult': args['adult'],
                  'children': args['children'],
                  'child': args['child'],
                  'items': args['items'],
                  'updatedAt': FieldValue.serverTimestamp(),
                };

                if (mode == 'edit' && docId != null) {
                  await FirebaseFirestore.instance
                      .collection('itineraries')
                      .doc(docId)
                      .update(firestoreData);
                } else {
                  await FirebaseFirestore.instance
                      .collection('itineraries')
                      .add({
                    ...firestoreData,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                }

                await Printing.layoutPdf(
                  onLayout: (_) =>
                      _buildExactPdf(args, groupedItems),
                );

                Navigator.pop(context);
              },
              child: const Text('Save & Download'),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= HELPERS =================

  static Map<String, List<String>> _groupByTime(List items) {
    final Map<String, List<String>> map = {};
    for (final e in items) {
      final time = e['to'] == null || e['to'].isEmpty
          ? e['from']
          : '${e['from']} – ${e['to']}';
      map.putIfAbsent(time, () => []);
      map[time]!.add(e['title']);
    }
    return map;
  }

 static String _to12Hr(String time) {
  final parts = time.split('-').map((e) => e.trim()).toList();

  DateTime parse(String t) {
    final dt = DateFormat('H:mm').parse(t);

    // 🔧 Fix ambiguous PM times like 6:00 → 18:00
    if (dt.hour < 8) {
      return dt.add(const Duration(hours: 12));
    }
    return dt;
  }

  String format(String t) =>
      DateFormat('hh:mm a').format(parse(t));

  return parts.length == 2
      ? '${format(parts[0])} - ${format(parts[1])}'
      : format(parts[0]);
}


  /// ================= TABLE UI =================

 Widget _buildTable(Map<String, List<String>> groupedItems) {
  const double rowHeight = 44; // fixed row height
  int serial = 1;

  return Column(
    children: [
      /// ================= HEADER =================
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: const Color.fromARGB(255, 52, 191, 59),
        ),
        child: const Row(
          children: [
            _Cell(width: 40, text: 'No', bold: true),
            _VLine(),
            _Cell(flex: 1, text: 'Item', bold: true),
            _VLine(),
            _Cell(width: 120, text: 'Time', bold: true),
          ],
        ),
      ),

      /// ================= BODY =================
      ...groupedItems.entries.map((entry) {
        final timeText = _to12Hr(entry.key);
        final items = entry.value;
        final totalHeight = items.length * rowHeight;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== NO + ITEM COLUMN =====
            Expanded(
              child: Column(
                children: List.generate(items.length, (index) {
                  return Container(
                    height: rowHeight,
                    decoration: const BoxDecoration(
                      border: Border(
                        left: BorderSide(color: Colors.black),
                        bottom: BorderSide(color: Colors.black),
                      ),
                    ),
                    child: Row(
                      children: [
                        _Cell(
                          width: 40,
                          text: (serial++).toString(),
                          color: Colors.green,
                        ),
                        const _VLine(),
                        _Cell(
                          flex: 1,
                          text: items[index],
                          color: Colors.green,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            /// ===== MERGED TIME COLUMN =====
            Container(
              width: 120,
              height: totalHeight,
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Colors.black),
                  right: BorderSide(color: Colors.black),
                  bottom: BorderSide(color: Colors.black),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    timeText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    ],
  );
}

  /// ================= PDF =================

 Future<Uint8List> _buildExactPdf(
  Map<String, dynamic> args,
  Map<String, List<String>> groupedItems,
) async {
  final pdf = pw.Document();

  final logo = await imageFromAssetBundle(
    'assets/images/neyyar_logo.png',
  );

  const double rowHeight = 30;
  const PdfColor kDarkGreen = PdfColor.fromInt(0xFF1B7F2A);

  int serial = 1;
  final List<pw.TableRow> tableRows = [];

  /// TABLE BODY WITH REAL MERGED TIME
  /// 
pw.Widget _buildPdfTable(Map<String, List<String>> groupedItems) {
  const double rowHeight = 44;
  int serial = 1;

  final List<pw.TableRow> rows = [];

  /// ================= HEADER =================
  rows.add(
    pw.TableRow(
      decoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF34BF3B),
      ),
      children: [
        _pdfHeaderCell('No', width: 40),
        _pdfHeaderCell('Item'),
        _pdfHeaderCell('Time', width: 120),
      ],
    ),
  );

  /// ================= BODY =================
  groupedItems.forEach((timeKey, items) {
    final timeText = _to12Hr(timeKey);
    final rowSpan = items.length;

    for (int i = 0; i < items.length; i++) {
      rows.add(
        pw.TableRow(
          children: [
            _pdfCell(
              (serial++).toString(),
              height: rowHeight,
              align: pw.TextAlign.center,
            ),

            _pdfCell(
              items[i],
              height: rowHeight,
            ),

            /// ===== REAL MERGED TIME COLUMN =====
           if (i == 0)
  pw.Container(
    height: rowHeight * rowSpan, // 👈 visual merge
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey),
    ),
    child: pw.Text(
      timeText,
      textAlign: pw.TextAlign.center,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  )
else
  pw.Container(
    height: rowHeight,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey),
    ),
  ),
          ],
        ),
      );
    }
  });

  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.black),
    columnWidths: {
      0: const pw.FixedColumnWidth(40),
      1: const pw.FlexColumnWidth(),
      2: const pw.FixedColumnWidth(120),
    },
    children: rows,
  );
}



  pdf.addPage(
    pw.Page(
      margin: const pw.EdgeInsets.all(24),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          /// HEADER
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Image(logo, height: 60),
              pw.SizedBox(width: 12),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      '${args['package']} ITINERARY',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      '${DateFormat('dd-MMM-yyyy').format(args['date'])} '
                      '(${_to12Hr(args['start'])} ${_to12Hr(args['end'])})',
                    ),
                  ],
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 16),

          /// ADDRESS
          pw.Text('To,'),
          pw.Text(args['name']),
          pw.Text('Mob: ${args['mobile']}'),

          pw.SizedBox(height: 12),

          /// INTRO
          pw.RichText(
            text: pw.TextSpan(
              children: [
                const pw.TextSpan(text: 'At '),
                pw.TextSpan(
                  text: 'Neyyar Heritage Inn - Home Stay ',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                const pw.TextSpan(
                  text:
                      'we are committed to providing our guests with exceptional experiences.',
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 10),

          /// PAX
          pw.Text(
            'No. of Pax: ${args['adult']} + ${args['children']} + ${args['child']} '
            '= ${args['adult'] + args['children'] + args['child']}',
          ),

          pw.SizedBox(height: 16),

          /// TABLE
          pw.Table(
            border: pw.TableBorder.all(),
            columnWidths: {
              0: const pw.FixedColumnWidth(30),
              1: const pw.FlexColumnWidth(),
              2: const pw.FixedColumnWidth(90),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: kDarkGreen),
                children: [
                  _pdfHeaderCell('No'),
                  _pdfHeaderCell('Item'),
                  _pdfHeaderCell('Time'),
                ],
              ),
              ...tableRows,
            ],
          ),

          pw.SizedBox(height: 16),

          /// TERMS
          pw.Text(
            'Terms & Conditions',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 6),
          pw.Bullet(text: 'No transportation available.'),
          pw.Bullet(text: 'If members are less than confirmed, inform 3 days in advance.'),
          pw.Bullet(text: 'Management reserves the right to reschedule.'),

          pw.Spacer(),

          /// FOOTER BAR (DARK GREEN)
          pw.Container(
            color: kDarkGreen,
            padding: const pw.EdgeInsets.all(8),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    '9656763391',
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'neyyarheritageinn@gmail.com',
                    textAlign: pw.TextAlign.center,
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'www.neyyarheritage.in',
                    textAlign: pw.TextAlign.right,
                    style: const pw.TextStyle(color: PdfColors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  return pdf.save();
}

/// ================= CELL HELPERS =================
static const PdfColor kDarkGreen = PdfColor.fromInt(0xFF34BF3B);

pw.Widget _pdfHeaderCell(
  String text, {
  double? width,
}) {
  return pw.Container(
    height: 44,
    width: width,
    alignment: pw.Alignment.center,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.black),
      color: const PdfColor.fromInt(0xFF34BF3B),
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        color: PdfColors.white,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  );
}

pw.Widget _pdfCell(
  String text, {
  double height = 44,
  pw.TextAlign align = pw.TextAlign.left,
  bool bold = false,
}) {
  return pw.Container(
    height: height,
    padding: const pw.EdgeInsets.symmetric(horizontal: 6),
    alignment: pw.Alignment.centerLeft,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.black),
    ),
    child: pw.Text(
      text,
      textAlign: align,
      style: pw.TextStyle(
        color: PdfColors.green,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}
}

/// ================= TABLE WIDGETS =================

class _Cell extends StatelessWidget {
  final double? width;
  final int? flex;
  final String text;
  final bool bold;
  final Color? color;

  const _Cell({
    this.width,
    this.flex,
    required this.text,
    this.bold = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.all(6),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
      ),
    );

    if (width != null) return SizedBox(width: width, child: child);
    return Expanded(flex: flex!, child: child);
  }
}

class _VLine extends StatelessWidget {
  const _VLine();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, color: Colors.black);
  }
}

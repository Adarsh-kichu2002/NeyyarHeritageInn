import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  Map<String, dynamic> billData = {};

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _invoiceCtrl = TextEditingController();

  DateTime? checkIn;
  DateTime? checkOut;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    billData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ??
            {};

    _nameCtrl.text = billData['customerName'] ?? '';
    _phoneCtrl.text = billData['phone1'] ?? '';

    /// INVOICE NUMBER
    _invoiceCtrl.text =
        billData['invoiceNo']?.toString() ??
            DateTime.now().millisecondsSinceEpoch.toString();

    /// SAFE DATE INIT
    checkIn = billData['checkInDate'];
    checkOut = billData['checkOutDate'];

    /// If both null (new bill), default logically
    checkIn ??= DateTime.now();
    checkOut ??= DateTime.now().add(const Duration(days: 1));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Bill')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Guest Name'),
            ),
            TextField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: _invoiceCtrl,
              decoration: const InputDecoration(labelText: 'Invoice Number'),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                _dateBtn(
                  'Check In',
                  checkIn,
                  (d) => setState(() => checkIn = d),
                ),
                const SizedBox(width: 8),
                _dateBtn(
                  'Check Out',
                  checkOut,
                  (d) => setState(() => checkOut = d),
                ),
              ],
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('Next'),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/bill_list',
                    arguments: {
                      ...billData,
                      'customerName': _nameCtrl.text.trim(),
                      'phone1': _phoneCtrl.text.trim(),
                      'invoiceNo': _invoiceCtrl.text.trim(),
                      'checkInDate': checkIn,
                      'checkOutDate': checkOut,
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateBtn(
    String label,
    DateTime? date,
    ValueChanged<DateTime> onPick,
  ) {
    return Expanded(
      child: OutlinedButton(
        child: Text(
          date == null
              ? label
              : DateFormat('dd/MM/yyyy').format(date),
        ),
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date ?? DateTime.now(),
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            onPick(picked);
          }
        },
      ),
    );
  }
}

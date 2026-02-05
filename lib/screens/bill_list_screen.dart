import 'package:flutter/material.dart';

class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  Map<String, dynamic> data = {};
  bool _initialized = false;

  final advanceCtrl = TextEditingController(text: '0');

  final List<Map<String, dynamic>> items = [];

  /// DEFAULT ITEMS
  final List<Map<String, dynamic>> defaultItems = [
    {'name': 'Mineral Water', 'qty': 0, 'price': 20},
    {'name': 'Soda', 'qty': 0, 'price': 40},
    {'name': 'Tea', 'qty': 0, 'price': 20},
    {'name': 'Coffee', 'qty': 0, 'price': 25},
    {'name': 'Porotta', 'qty': 0, 'price': 15},
    {'name': 'Chicken Roast', 'qty': 0, 'price': 250},
    {'name': 'Chicken Fry', 'qty': 0, 'price': 250},
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    /// PREFILL FROM QUOTATION ROOMS
    final rooms = (data['rooms'] ?? []) as List;
    for (final r in rooms.where((r) => r['selected'] == true)) {
      items.add({
        'name': r['name'],
        'qty': r['qty'] ?? 1,
        'price': r['price'] ?? 0,
      });
    }

    /// EXTRA PERSONS
    if ((data['extraTotal'] ?? 0) > 0) {
      items.add({
        'name': 'Extra Persons',
        'qty': data['extraPersons'] ?? 1,
        'price': data['extraPersonPrice'] ?? 0,
      });
    }

    /// ADD DEFAULT ITEMS
    items.addAll(defaultItems.map((e) => Map<String, dynamic>.from(e)));
  }

  /// TOTAL CALCULATIONS
  int get subtotal => items.fold(
        0,
        (s, i) =>
            s +
            ((int.tryParse(i['qty'].toString()) ?? 0) *
                (int.tryParse(i['price'].toString()) ?? 0)),
      );

  int get gst => (subtotal * 0.05).round();
  int get advance => int.tryParse(advanceCtrl.text) ?? 0;
  int get balance => subtotal + gst - advance;

  void _addItem() {
    setState(() {
      items.add({'name': '', 'qty': 1, 'price': 0});
    });
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bill Items')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => _itemEditor(i),
              ),
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
            ),

            const Divider(),

            TextField(
              controller: advanceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Advance'),
              onChanged: (_) => setState(() {}),
            ),

            const SizedBox(height: 8),

            _amountRow('Subtotal', subtotal),
            _amountRow('GST (5%)', gst),
            _amountRow('Balance', balance, bold: true),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                child: const Text('Preview Bill'),
                onPressed: () {
                  /// 🔑 FILTER ITEMS WITH QTY > 0 ONLY
                  final previewItems = items
                      .where((i) =>
                          (int.tryParse(i['qty'].toString()) ?? 0) > 0)
                      .toList();

                  Navigator.pushNamed(
                    context,
                    '/bill_preview',
                    arguments: {
                      ...data,
                      'items': previewItems,
                      'subtotal': subtotal,
                      'gst': gst,
                      'advance': advance,
                      'balance': balance,
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

  /// ITEM EDITOR
  Widget _itemEditor(int index) {
    final item = items[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Item Name'),
              controller: TextEditingController(text: item['name']),
              onChanged: (v) => item['name'] = v,
            ),

            const SizedBox(height: 6),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Qty'),
                    keyboardType: TextInputType.number,
                    controller:
                        TextEditingController(text: item['qty'].toString()),
                    onChanged: (v) {
                      item['qty'] = int.tryParse(v) ?? 0;
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    controller:
                        TextEditingController(text: item['price'].toString()),
                    onChanged: (v) {
                      item['price'] = int.tryParse(v) ?? 0;
                      setState(() {});
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// AMOUNT ROW
  Widget _amountRow(String label, int value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
        Text(
          '₹$value',
          style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
        ),
      ],
    );
  }
}

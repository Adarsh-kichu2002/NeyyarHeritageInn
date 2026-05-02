import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Map<String, dynamic> data = {};
  bool _initialized = false;

  /// 🔴 ADVANCE (READ ONLY)
  int advanceAmount = 0;

  /// 🟢 DISCOUNT (EDITABLE)
  final discountCtrl = TextEditingController(text: '0');

  final List<Map<String, dynamic>> items = [];

  Map<String, dynamic> _createItem(String name, int qty, int price) {
    return {
      'name': name,
      'qty': qty,
      'price': price,
      'nameCtrl': TextEditingController(text: name),
      'qtyCtrl': TextEditingController(text: qty.toString()),
      'priceCtrl': TextEditingController(text: price.toString()),
    };
  }

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
    final bool isEdit = data['isEdit'] == true;

    /// 🔴 GET ADVANCE FROM QUOTATION (READ ONLY)
    advanceAmount = data['advance'] ?? 0;

    /// 🟢 LOAD DISCOUNT IF EXISTS
    discountCtrl.text = (data['discount'] ?? 0).toString();

    items.clear();

    /// ===============================
    /// EDIT MODE
    /// ===============================
    if (isEdit && data['items'] != null) {
      final savedItems = (data['items'] as List).map((e) {
        final item = Map<String, dynamic>.from(e);
        item['nameCtrl'] = TextEditingController(text: item['name']);
        item['qtyCtrl'] =
            TextEditingController(text: item['qty'].toString());
        item['priceCtrl'] =
            TextEditingController(text: item['price'].toString());
        return item;
      }).toList();

      items.addAll(savedItems);

      for (final defaultItem in defaultItems) {
        final exists =
            savedItems.any((e) => e['name'] == defaultItem['name']);

        if (!exists) {
          items.add(_createItem(
              defaultItem['name'], defaultItem['qty'], defaultItem['price']));
        }
      }

      return;
    }

    /// ===============================
    /// CREATE MODE
    /// ===============================
    final rooms = (data['rooms'] ?? []) as List;

    for (final r in rooms.where((r) => r['selected'] == true)) {
      items.add(_createItem(
        r['name'],
        r['qty'] ?? 1,
        r['price'] ?? 0,
      ));
    }

    if ((data['extraTotal'] ?? 0) > 0) {
      items.add(_createItem(
        'Extra Persons',
        data['extraPersons'] ?? 1,
        data['extraPersonPrice'] ?? 0,
      ));
    }

    items.addAll(defaultItems.map(
        (e) => _createItem(e['name'], e['qty'], e['price'])));
  }

  /// ===============================
  /// CALCULATIONS
  /// ===============================

  int get subtotal => items.fold(
        0,
        (s, i) =>
            s +
            ((int.tryParse(i['qty'].toString()) ?? 0) *
                (int.tryParse(i['price'].toString()) ?? 0)),
      );

  int get gst => (subtotal * 0.05).round();

  int get discount => int.tryParse(discountCtrl.text) ?? 0;

  /// 🔴 NEW LOGIC
  int get balance => subtotal + gst - advanceAmount - discount;

  void _addItem() {
    setState(() {
      items.add(_createItem('', 1, 0));
    });
  }

  void _removeItem(int index) {
    final item = items[index];
    item['nameCtrl']?.dispose();
    item['qtyCtrl']?.dispose();
    item['priceCtrl']?.dispose();

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

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _addItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
              ),
            ),

            const Divider(),

            /// 🔴 ADVANCE (READ ONLY)
            _amountRow('Advance', advanceAmount),

            /// 🟢 DISCOUNT FIELD
            TextField(
              controller: discountCtrl,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: 'Discount'),
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
  final previewItems = items
      .where((i) =>
          (int.tryParse(i['qty'].toString()) ?? 0) > 0)
      .map((i) => {
            'name': i['name'],
            'qty': int.tryParse(i['qty'].toString()) ?? 0,
            'price': int.tryParse(i['price'].toString()) ?? 0,
          })
      .toList();

  final billData = {
    ...data,
    'items': previewItems,
    'subtotal': subtotal,
    'gst': gst,
    'advance': advanceAmount,
    'discount': discount,
    'balance': balance,

    /// 🔥 VERY IMPORTANT
    'billId': data['billId'] ??
        DateTime.now().millisecondsSinceEpoch.toString(),
  };

  Navigator.pushNamed(
    context,
    '/bill_preview',
    arguments: billData,
  );
},
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (var item in items) {
      item['nameCtrl']?.dispose();
      item['qtyCtrl']?.dispose();
      item['priceCtrl']?.dispose();
    }
    discountCtrl.dispose();
    super.dispose();
  }

  Widget _itemEditor(int index) {
    final item = items[index];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            TextField(
              controller: item['nameCtrl'],
              decoration:
                  const InputDecoration(labelText: 'Item Name'),
              onChanged: (v) => item['name'] = v,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: item['qtyCtrl'],
                    decoration:
                        const InputDecoration(labelText: 'Qty'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      item['qty'] = int.tryParse(v) ?? 0;
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: item['priceCtrl'],
                    decoration:
                        const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) {
                      item['price'] = int.tryParse(v) ?? 0;
                      setState(() {});
                    },
                  ),
                ),
                IconButton(
                  icon:
                      const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _removeItem(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _amountRow(String label, int value,
      {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight:
                    bold ? FontWeight.bold : null)),
        Text(
          '₹$value',
          style: TextStyle(
              fontWeight:
                  bold ? FontWeight.bold : null),
        ),
      ],
    );
  }
}

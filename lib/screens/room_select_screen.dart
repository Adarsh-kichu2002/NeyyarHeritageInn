import 'package:flutter/material.dart';

class RoomSelectScreen extends StatefulWidget {
  const RoomSelectScreen({super.key});

  @override
  State<RoomSelectScreen> createState() => _RoomSelectScreenState();
}

class _RoomSelectScreenState extends State<RoomSelectScreen> {
  late Map<String, dynamic> quotationData;

  /// ROOMS
  late List<Map<String, dynamic>> rooms;

  /// EXTRA PERSONS
  final TextEditingController extraPersonCtrl =
      TextEditingController(text: '0');
  final TextEditingController extraPersonPriceCtrl =
      TextEditingController(text: '1000');

  /// CUSTOM ITEM
  final TextEditingController customItemNameCtrl = TextEditingController();
  final TextEditingController customItemPriceCtrl =
      TextEditingController(text: '0');

  /// DISCOUNT
  final TextEditingController discountCtrl =
      TextEditingController(text: '0');

  /// FACILITIES
  late List<String> facilities;
  final TextEditingController facilityCtrl = TextEditingController();

  bool _initialized = false;

  @override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (_initialized) return;

  quotationData =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

  final isEdit = quotationData['mode'] == 'edit';

  /// ROOMS
  rooms = isEdit && quotationData['rooms'] != null
      ? List<Map<String, dynamic>>.from(
          quotationData['rooms'].map((r) => Map<String, dynamic>.from(r)))
      : [
          {'name': 'AC Suite Room', 'price': 3500, 'qty': 1, 'selected': false},
          {'name': 'Hut', 'price': 2500, 'qty': 1, 'selected': false},
          {'name': 'Non-AC Room', 'price': 2000, 'qty': 1, 'selected': false},
        ];

  /// EXTRA & DISCOUNT
  extraPersonCtrl.text =
      isEdit ? quotationData['extraPersons']?.toString() ?? '0' : '0';
  extraPersonPriceCtrl.text =
      isEdit ? quotationData['extraPersonPrice']?.toString() ?? '1000' : '1000';
  discountCtrl.text =
      isEdit ? quotationData['discount']?.toString() ?? '0' : '0';

  /// FACILITIES
  facilities = isEdit && quotationData['facilities'] != null
      ? List<String>.from(quotationData['facilities'])
      : [
          'Welcome Drinks',
          'Medium Pool (2 Hrs)',
          'Waterfall & Rain Dance (30 minutes)',
          'Children Play Area',
          'Breakfast (Next Day)',
        ];

  _initialized = true;
}


  int get roomTotal => rooms
      .where((r) => r['selected'])
      .fold(0, (s, r) => s + (r['price'] * r['qty']) as int);

  int get extraTotal =>
      (int.tryParse(extraPersonCtrl.text) ?? 0) *
      (int.tryParse(extraPersonPriceCtrl.text) ?? 0);

  int get discount => int.tryParse(discountCtrl.text) ?? 0;

  int get grandTotal =>
      (roomTotal + extraTotal - discount).clamp(0, 999999);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Rooms')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Rooms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          ...rooms.map(_roomTile),

          const SizedBox(height: 12),

          /// CUSTOM ITEM
          Row(children: [
            Expanded(
              child: TextField(
                controller: customItemNameCtrl,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: customItemPriceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
            ),
          ]),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              if (customItemNameCtrl.text.isEmpty) return;
              setState(() {
                rooms.add({
                  'name': customItemNameCtrl.text.trim(),
                  'price': int.tryParse(customItemPriceCtrl.text) ?? 0,
                  'qty': 1,
                  'selected': true,
                });
                customItemNameCtrl.clear();
                customItemPriceCtrl.text = '0';
              });
            },
            child: const Text('Add Custom Item'),
          ),

          const Divider(height: 32),

          /// EXTRA PERSONS
          const Text('Extra Persons'),
          Row(children: [
            _smallBox(extraPersonCtrl, 'Persons'),
            const SizedBox(width: 8),
            _smallBox(extraPersonPriceCtrl, 'Price'),
            const SizedBox(width: 8),
            Text('₹$extraTotal'),
          ]),

          const Divider(height: 32),

          /// FACILITIES
          const Text('Facilities',
              style: TextStyle(fontWeight: FontWeight.bold)),
          ...facilities.map((f) => Row(children: [
                const Text('• '),
                Expanded(child: Text(f)),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => facilities.remove(f)),
                )
              ])),
          Row(children: [
            Expanded(
              child: TextField(
                controller: facilityCtrl,
                decoration: const InputDecoration(hintText: 'Add facility'),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (facilityCtrl.text.isEmpty) return;
                setState(() {
                  facilities.add(facilityCtrl.text.trim());
                  facilityCtrl.clear();
                });
              },
            )
          ]),

          const Divider(height: 32),

          /// DISCOUNT
          TextField(
            controller: discountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Discount Amount',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),

          const SizedBox(height: 20),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: ₹$grandTotal',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 24),

          /// PREVIEW
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/quotation_preview_screen',
                arguments: {
                  ...quotationData, // 🔥 keeps mode + quotationId
                  'rooms': rooms,
                  'extraPersons': extraPersonCtrl.text,
                  'extraPersonPrice': extraPersonPriceCtrl.text,
                  'extraTotal': extraTotal,
                  'discount': discount,
                  'facilities': facilities,
                  'total': grandTotal,
                },
              );
            },
            child: const Text('Preview Quotation'),
          ),
        ]),
      ),
    );
  }

  Widget _roomTile(Map<String, dynamic> room) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          Checkbox(
            value: room['selected'],
            onChanged: (v) => setState(() => room['selected'] = v),
          ),
          Expanded(flex: 3, child: Text(room['name'])),

          SizedBox(
            width: 50,
            child: TextField(
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              controller:
                  TextEditingController(text: room['qty'].toString()),
              onChanged: (v) {
                room['qty'] = (int.tryParse(v) ?? 1).clamp(1, 999);
                setState(() {});
              },
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 80,
            child: TextField(
              keyboardType: TextInputType.number,
              controller:
                  TextEditingController(text: room['price'].toString()),
              onChanged: (v) {
                room['price'] = int.tryParse(v) ?? room['price'];
                setState(() {});
              },
            ),
          ),

          const SizedBox(width: 8),

          Text(
            '₹${room['price'] * room['qty']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ]),
      ),
    );
  }

  Widget _smallBox(TextEditingController c, String label) {
    return Expanded(
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}

// create_itinerary.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateItineraryScreen extends StatefulWidget {
  const CreateItineraryScreen({super.key});

  @override
  State<CreateItineraryScreen> createState() => _CreateItineraryScreenState();
}

class _CreateItineraryScreenState extends State<CreateItineraryScreen> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool isEdit = false;
  String? docId;
  bool _initialized = false;

  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();
  final guideNameCtrl = TextEditingController();
  final guidePhoneCtrl = TextEditingController();

  /// PACKAGE DROPDOWN
  final List<String> packageOptions = [
    'DAY OUT',
    'STAY',
    'STAY PACKAGE',
    'ADD'
  ];

  String packageName = 'DAY OUT';

  /// CONFIRMED GUESTS DROPDOWN
  List<Map<String, dynamic>> confirmedGuests = [];
  String? selectedGuest;

  DateTime date = DateTime.now();
  TimeOfDay start = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay end = const TimeOfDay(hour: 18, minute: 0);

  final adultCtrl = TextEditingController();
  final childrenCtrl = TextEditingController();
  final childCtrl = TextEditingController();

  int _timeToMinutes(String time) {
    try {
      final dt = DateFormat('H:mm').parse(time);
      return dt.hour * 60 + dt.minute;
    } catch (_) {
      return 0;
    }
  }

  List<Map<String, TextEditingController>> items = [
    _item('Welcome Drinks (Neyyar Dam Cafe)', '10:00', '12:00'),
    _item('Jungle Boat Safari', '10:00', '12:00'),
    _item('Crocodile & Deer Park Visit [Boating]', '10:00', '12:00'),
    _item('Check-in - Neyyar Heritage Inn', '12:00', ''),
    _item('Lunch - Samudra Sadhya', '13:30', '14:00'),
    _item('Pool with waterfall and Rain dance', '14:00', '15:30'),
    _item('Tea & Snacks', '15:30', '16:00'),
    _item('Mayam Kadavu Visit & Kalipara Trekking', '16:00', '18:00')
  ];

  static Map<String, TextEditingController> _item(
      String title, String from, String to) {
    return {
      'title': TextEditingController(text: title),
      'from': TextEditingController(text: from),
      'to': TextEditingController(text: to),
    };
  }

  int get totalPax {
    final adult = int.tryParse(adultCtrl.text) ?? 0;
    final children = int.tryParse(childrenCtrl.text) ?? 0;
    final child = int.tryParse(childCtrl.text) ?? 0;
    return adult + children + child;
  }

  /// LOAD CONFIRMED GUESTS BASED ON DATE
  Future<void> loadConfirmedGuests() async {
    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snap = await _db
        .collection('confirmed_quotations')
        .where('checkInDate', isGreaterThanOrEqualTo: startDate)
        .where('checkInDate', isLessThanOrEqualTo: endDate)
        .get();

    confirmedGuests = snap.docs.map((d) {
      final data = d.data();
      return {
        'name': data['customerName'],
        'adult': data['adult'] ?? 0,
        'children': data['children'] ?? 0,
        'child': data['child'] ?? 0,
        'phone': data['phone1'] ?? '',
      };
    }).toList();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    loadConfirmedGuests();
  }

  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  if (_initialized) return;

  final args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

  if (args != null) {
    if (args['mode'] == 'edit') {
      isEdit = true;
      docId = args['docId'];

      nameCtrl.text = args['name'] ?? '';
      mobileCtrl.text = args['mobile'] ?? '';
      guideNameCtrl.text = args['guideName'] ?? '';
      guidePhoneCtrl.text = args['guidePhone'] ?? '';

      adultCtrl.text = (args['adult'] ?? 0).toString();
      childrenCtrl.text = (args['children'] ?? 0).toString();
      childCtrl.text = (args['child'] ?? 0).toString();

      packageName = args['package'] ?? 'DAY OUT';

      if (args['date'] != null) {
        date = args['date'];
      }

      /// LOAD ITINERARY ITEMS
      if (args['items'] != null) {
        items.clear();

        for (var item in args['items']) {
          items.add({
            'title': TextEditingController(text: item['title']),
            'from': TextEditingController(text: item['from']),
            'to': TextEditingController(text: item['to']),
          });
        }
      }
    }
  }

  _initialized = true;
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Itinerary'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () =>
                Navigator.pushNamed(context, '/itinerary_history'),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            /// PACKAGE DROPDOWN
            DropdownButtonFormField<String>(
  value: packageOptions.contains(packageName) ? packageName : null,
  decoration: const InputDecoration(labelText: 'Package'),
  items: packageOptions
      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
      .toList(),
  onChanged: (v) async {
    if (v == 'ADD') {
      final ctrl = TextEditingController();

      final result = await showDialog<String>(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: const Text("Enter Package Name"),
            content: TextField(controller: ctrl),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, ctrl.text),
                child: const Text("Save"),
              ),
            ],
          );
        },
      );

      if (result != null && result.trim().isNotEmpty) {
        setState(() {
          if (!packageOptions.contains(result)) {
            packageOptions.insert(packageOptions.length - 1, result);
          }
          packageName = result;
        });
      }
    } else {
      setState(() => packageName = v!);
    }
  },
),

            const SizedBox(height: 12),

            /// DATE
            Row(
              children: [
                Expanded(
                  child: _boxed(
                      onTap: _pickDate,
                      child: Text(DateFormat('dd MMM yyyy').format(date))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _boxed(
                      onTap: () => _pickTime(true),
                      child: Text(start.format(context))),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _boxed(
                      onTap: () => _pickTime(false),
                      child: Text(end.format(context))),
                ),
              ],
            ),

            const Divider(height: 32),

            /// GUEST DROPDOWN
            DropdownButtonFormField<String>(
              hint: const Text("Select Guest"),
              value: selectedGuest,
              items: [
                ...confirmedGuests.map((g) {
                  return DropdownMenuItem(
                    value: g['name'],
                    child: Text(g['name']),
                  );
                }),
                const DropdownMenuItem(
                    value: "ADD", child: Text("ADD MANUAL ENTRY"))
              ],
              onChanged: (v) {
                if (v == "ADD") {
                  setState(() {
                    selectedGuest = null;
                    nameCtrl.clear();
                    mobileCtrl.clear();
                  });
                  return;
                }

                final guest =
                    confirmedGuests.firstWhere((g) => g['name'] == v);

                nameCtrl.text = guest['name'];
                mobileCtrl.text = guest['phone'];

                adultCtrl.text = guest['adult'].toString();
                childrenCtrl.text = guest['children'].toString();
                childCtrl.text = guest['child'].toString();

                setState(() => selectedGuest = v);
              },
            ),

            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Guest Name'),
            ),

            TextFormField(
              controller: mobileCtrl,
              decoration: const InputDecoration(labelText: 'Mobile'),
            ),

            const Divider(height: 32),

            /// GUIDE DETAILS
            const Text("Guide Details",
                style: TextStyle(fontWeight: FontWeight.bold)),

            TextField(
              controller: guideNameCtrl,
              decoration: const InputDecoration(labelText: "Guide Name"),
            ),

            TextField(
              controller: guidePhoneCtrl,
              decoration: const InputDecoration(labelText: "Guide Phone"),
            ),

            const Divider(height: 32),

            /// PAX
            const Text('No. of Pax',
                style: TextStyle(fontWeight: FontWeight.bold)),

            Row(
              children: [
                _paxBox('Adult', adultCtrl),
                _paxBox('Children', childrenCtrl),
                _paxBox('Child', childCtrl),
              ],
            ),

            const SizedBox(height: 8),
            Text('Total: $totalPax'),

            const Divider(height: 32),

            const Text('Itinerary',
                style: TextStyle(fontWeight: FontWeight.bold)),

            ...items.map(_itemRow),

            TextButton.icon(
              onPressed: () {
                setState(() {
                  items.add(_item('', '', ''));
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Item'),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _preview,
              child: const Text('Preview Itinerary'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _boxed({required Widget child, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        child: child,
      ),
    );
  }

  Widget _paxBox(String label, TextEditingController ctrl) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  Widget _itemRow(Map<String, TextEditingController> item) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 4),
    child: Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [

          /// TITLE + DELETE BUTTON
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: item['title'],
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
              ),

              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  if (items.length == 1) return; // prevent deleting last item

                  setState(() {
                    // Dispose controllers properly
                    item['title']?.dispose();
                    item['from']?.dispose();
                    item['to']?.dispose();

                    items.remove(item);
                  });
                },
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// FROM + TO
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: item['from'],
                  decoration: const InputDecoration(labelText: 'From'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: item['to'],
                  decoration: const InputDecoration(labelText: 'To'),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

  void _preview() {
    if (!_formKey.currentState!.validate()) return;

    final sortedItems = items
        .map((e) => {
              'title': e['title']!.text,
              'from': e['from']!.text,
              'to': e['to']!.text,
            })
        .toList()
      ..sort((a, b) =>
          _timeToMinutes(a['from']!).compareTo(_timeToMinutes(b['from']!)));

    Navigator.pushNamed(
      context,
      '/itinerary_preview',
      arguments: {
        'package': packageName,
        'date': date,
        'start': start.format(context),
        'end': end.format(context),
        'name': nameCtrl.text,
        'mobile': mobileCtrl.text,
        'adult': int.tryParse(adultCtrl.text) ?? 0,
        'children': int.tryParse(childrenCtrl.text) ?? 0,
        'child': int.tryParse(childCtrl.text) ?? 0,
        'guideName': guideNameCtrl.text,
        'guidePhone': guidePhoneCtrl.text,
        'items': sortedItems,
        'docId': docId,
      },
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (d != null) {
      setState(() => date = d);
      loadConfirmedGuests();
    }
  }

  Future<void> _pickTime(bool isStart) async {
    final t = await showTimePicker(
      context: context,
      initialTime: isStart ? start : end,
    );
    if (t != null) {
      setState(() => isStart ? start = t : end = t);
    }
  }
}

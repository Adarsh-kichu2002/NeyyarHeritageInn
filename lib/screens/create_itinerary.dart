import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateItineraryScreen extends StatefulWidget {
  const CreateItineraryScreen({super.key});

  @override
  State<CreateItineraryScreen> createState() => _CreateItineraryScreenState();
}

class _CreateItineraryScreenState extends State<CreateItineraryScreen> {
  final _formKey = GlobalKey<FormState>();

  bool isEdit = false;
  String? docId;


  final nameCtrl = TextEditingController();
  final mobileCtrl = TextEditingController();

  String packageName = 'DAY OUT';

  DateTime date = DateTime.now();
  TimeOfDay start = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay end = const TimeOfDay(hour: 18, minute: 0);

  int _timeToMinutes(String time) {
  try {
    final dt = DateFormat('H:mm').parse(time);
    return dt.hour * 60 + dt.minute;
  } catch (_) {
    return 0; // fallback if empty/invalid
  }
}

final adultCtrl = TextEditingController();
final childrenCtrl = TextEditingController();
final childCtrl = TextEditingController();


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
    String title,
    String from,
    String to,
  ) {
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



  @override
void didChangeDependencies() {
  super.didChangeDependencies();

  final args =
      ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

  if (args != null && args['mode'] == 'edit' && !isEdit) {
    isEdit = true;
    docId = args['docId'];

    packageName = args['package'] ?? 'DAY OUT';
    nameCtrl.text = args['name'] ?? '';
    mobileCtrl.text = args['mobile'] ?? '';

    if (args['date'] is DateTime) {
      date = args['date'];
    }

   adultCtrl.text = (args['adult'] ?? '').toString();
   childrenCtrl.text = (args['children'] ?? '').toString();
   childCtrl.text = (args['child'] ?? '').toString();

    // Load items
    if (args['items'] != null) {
      items = (args['items'] as List)
          .map<Map<String, TextEditingController>>((e) {
        return {
          'title': TextEditingController(text: e['title']),
          'from': TextEditingController(text: e['from']),
          'to': TextEditingController(text: e['to']),
        };
      }).toList();
    }

    setState(() {});
  }
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
            _boxed(
              child: TextFormField(
                initialValue: packageName,
                decoration: const InputDecoration(
                  labelText: 'Package',
                  border: InputBorder.none,
                ),
                onChanged: (v) => packageName = v,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _boxed(
                    onTap: _pickDate,
                    child: Text(DateFormat('dd MMM yyyy').format(date)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _boxed(
                    onTap: () => _pickTime(true),
                    child: Text(start.format(context)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _boxed(
                    onTap: () => _pickTime(false),
                    child: Text(end.format(context)),
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            TextFormField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Guest Name'),
              validator: (v) =>
                  v == null || v.isEmpty ? 'Name required' : null,
            ),
            TextFormField(
              controller: mobileCtrl,
              decoration: const InputDecoration(labelText: 'Mobile Number'),
              keyboardType: TextInputType.phone,
              validator: (v) =>
                  v == null || v.isEmpty ? 'Mobile required' : null,
            ),

            const Divider(height: 32),

            const Text('No. of Pax',
                style: TextStyle(fontWeight: FontWeight.bold)),

            const SizedBox(height: 8),

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

            const SizedBox(height: 8),

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
          _timeToMinutes(a['from']!)
              .compareTo(_timeToMinutes(b['from']!)));

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
    'adult': int.parse(adultCtrl.text),
    'children': int.parse(childrenCtrl.text),
    'child': int.parse(childCtrl.text),
    'items': sortedItems,

    /// 🔥 VERY IMPORTANT
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
    if (d != null) setState(() => date = d);
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

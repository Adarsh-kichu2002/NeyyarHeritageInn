import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryHistoryTab extends StatelessWidget {
  final List<QueryDocumentSnapshot> docs;

  const ItineraryHistoryTab({
    super.key,
    required this.docs,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: docs.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data() as Map<String, dynamic>;

        return ListTile(
          leading: Text('${index + 1}'),
          title: Text(data['name'] ?? '-'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data['mobile'] ?? '-'),
              Text('Package: ${data['package'] ?? 'Day Out'}'),
              Text(
                'Check-in: ${_fmtDate(data['checkInDate'])}  |  '
                'Check-out: ${_fmtDate(data['checkOutDate'])}',
              ),
            ],
          ),
          trailing: Wrap(
            spacing: 4,
            children: [
              /// 👁 VIEW
              IconButton(
                icon: const Icon(Icons.visibility),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/itinerary_preview',
                    arguments: {
                      ...data,
                      'docId': doc.id,
                      'mode': 'view',
                    },
                  );
                },
              ),

              /// ✏ EDIT
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/create_itinerary',
                    arguments: {
                      ...data,
                      'docId': doc.id,
                      'mode': 'edit',
                    },
                  );
                },
              ),

              /// 🗑 DELETE
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete Itinerary'),
                      content: const Text('Are you sure?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await FirebaseFirestore.instance
                        .collection('itineraries')
                        .doc(doc.id)
                        .delete();
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _fmtDate(dynamic d) {
    if (d == null) return '-';
    if (d is Timestamp) {
      return d.toDate().toString().split(' ').first;
    }
    return d.toString();
  }
}

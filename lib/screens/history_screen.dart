import 'package:flutter/material.dart';
import 'package:neyyar_heritage/screens/bill_history_tab.dart';
import 'quotation_history_tab.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('History'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Quotations'),
              Tab(text: 'Bills'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            QuotationHistoryTab(),
            BillHistoryTab(),
          ],
        ),
      ),
    );
  }
}

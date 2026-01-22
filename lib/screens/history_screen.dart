import 'package:flutter/material.dart';
import 'package:neyyar_heritage/screens/bill_history_tab.dart';
import 'quotation_history_tab.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Quotations'),
              Tab(text: 'Bills'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                QuotationHistoryTab(),
                BillHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

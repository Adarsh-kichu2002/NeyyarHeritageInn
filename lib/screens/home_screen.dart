import 'package:flutter/material.dart';
import 'package:neyyar_heritage/screens/history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _currentIndex == 0 ? _homeContent(context) : const HistoryScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }

  Widget _homeContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Image.asset('assets/images/neyyar_logo.png', height: 80),
          const SizedBox(height: 40),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _actionBox(context,
                    icon: Icons.description,
                    title: 'Create Quotation',
                    route: '/create_quotation'),
                _actionBox(context,
                    icon: Icons.receipt_long,
                    title: 'Create Bill',
                    route: '/bill_screen'),
                _actionBox(context,
                    icon: Icons.time_to_leave_outlined,
                    title: 'Create Itinerary',
                    route: '/create_itinerary'),    
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBox(BuildContext context,
      {required IconData icon,
      required String title,
      required String route}) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Card(
        elevation: 4,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.blue),
              const SizedBox(height: 10),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_quotation_screen.dart';
import 'screens/room_select_screen.dart';
import 'screens/quotation_preview_screen.dart';
import 'screens/history_screen.dart';
import 'screens/quotation_history_tab.dart';
import 'history/quotation_history_store.dart';
import 'screens/bill_screen.dart';
import 'screens/bill_list_screen.dart';
import 'screens/bill_preview_screen.dart';
import 'history/bill_history_store.dart';
import 'screens/bill_history_tab.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


void main() {
  runApp(
    DevicePreview(
      enabled: true, 
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => QuotationHistoryStore(),
          ),
          ChangeNotifierProvider(
            create: (_) => BillHistoryStore(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Neyyar Heritage Inn',

      // REQUIRED for DevicePreview
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,

      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
routes: {
  '/': (context) => const SplashScreen(),
  '/welcome': (context) => const WelcomeScreen(),
  '/home': (context) => const HomeScreen(),
  '/create_quotation': (context) => const CreateQuotationScreen(),
  '/room_select_screen': (context) => const RoomSelectScreen(),
  '/quotation_preview_screen': (context) => const QuotationPreviewScreen(),
  '/history': (context) => const HistoryScreen(),
  '/quotation_history_tab': (context) => const QuotationHistoryTab(),
  '/bill_screen': (_) => const BillScreen(),
  '/bill_list': (_) => const BillListScreen(),
  '/bill_preview': (_) => const BillPreviewScreen(),
  '/bill_history_tab': (context) => const BillHistoryTab(),
},
    );
  }
}

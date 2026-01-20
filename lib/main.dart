import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/create_quotation_screen.dart';
import 'screens/room_select_screen.dart';
import 'screens/quotation_preview_screen.dart';
import 'screens/create_bill_screen.dart.dart';
import 'screens/history_screen.dart';
import 'screens/quotation_history_tab.dart';
import 'history/quotation_history_store.dart';

  

void main() {
  runApp(
    DevicePreview(
      enabled: true, 
      builder: (context) => MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => QuotationHistoryStore(),
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
  '/create_bill': (context) => const CreateBillScreen(),
  '/history': (context) => const HistoryScreen(),
  '/quotation_history_tab': (context) => const QuotationHistoryTab(),
},
    );
  }
}
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'screens/inbox_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  LiquidGlassWidgets.initialize(
    enablePerformanceMonitor: false,
  );

  runApp(
    const ProviderScope(
      child: FinalActivityApp(),
    ),
  );
}

class FinalActivityApp extends StatelessWidget {
  const FinalActivityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'SchoolMail',
      home: InboxScreen(),
    );
  }
}
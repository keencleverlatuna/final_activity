import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'providers/theme_provider.dart';
import 'screens/inbox_screen.dart';

void main() {
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

class FinalActivityApp extends ConsumerWidget {
  const FinalActivityApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return themeState.when(
      loading: () {
        return const CupertinoApp(
          debugShowCheckedModeBanner: false,
          home: CupertinoPageScaffold(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return const CupertinoApp(
          debugShowCheckedModeBanner: false,
          home: CupertinoPageScaffold(
            child: Center(
              child: Text(
                'Unable to load app settings.',
              ),
            ),
          ),
        );
      },
      data: (theme) {
        final isDark = theme == AppTheme.dark;

        return CupertinoApp(
          debugShowCheckedModeBanner: false,
          theme: CupertinoThemeData(
            brightness:
            isDark ? Brightness.dark : Brightness.light,
            primaryColor: isDark
                ? const Color(0xFF90CAF9)
                : const Color(0xFF4F91C8),
            scaffoldBackgroundColor: isDark
                ? const Color(0xFF101820)
                : const Color(0xFFF3F7FA),
            barBackgroundColor: isDark
                ? const Color(0xFF18232D)
                : const Color(0xFFF7F9FC),
            textTheme: CupertinoTextThemeData(
              textStyle: TextStyle(
                color: isDark
                    ? const Color(0xFFF1F5F8)
                    : const Color(0xFF18232D),
              ),
            ),
          ),
          home: const InboxScreen(),
        );
      },
    );
  }
}
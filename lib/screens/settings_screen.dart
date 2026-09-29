import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          themeState.when(
            loading: () {
              return const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF18232D),
                ),
              );
            },
            error: (error, stackTrace) {
              return const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF18232D),
                ),
              );
            },
            data: (theme) {
              final isDark = theme == AppTheme.dark;

              return Text(
                'Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFFF1F5F8)
                      : const Color(0xFF18232D),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                14,
                0,
                14,
                120,
              ),
              children: [
                GlassContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: themeState.when(
                      loading: () {
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      },
                      error: (error, stackTrace) {
                        return const Text(
                          'Unable to load settings.',
                          style: TextStyle(
                            color: Color(0xFF71808C),
                          ),
                        );
                      },
                      data: (theme) {
                        final isDark = theme == AppTheme.dark;

                        final primaryText = isDark
                            ? const Color(0xFFF1F5F8)
                            : const Color(0xFF18232D);

                        final secondaryText = isDark
                            ? const Color(0xFFB8C5CE)
                            : const Color(0xFF71808C);

                        final iconColor = isDark
                            ? const Color(0xFFDCE8F0)
                            : const Color(0xFF405260);

                        return Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Appearance',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: primaryText,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Change the app appearance.',
                              style: TextStyle(
                                fontSize: 13,
                                color: secondaryText,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF25333E)
                                    : const Color(0xFFEAF0F4),
                                borderRadius:
                                BorderRadius.circular(18),
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF3B4C59)
                                      : const Color(0xFFD5DEE5),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isDark
                                        ? CupertinoIcons.moon_fill
                                        : CupertinoIcons.sun_max_fill,
                                    size: 24,
                                    color: iconColor,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      isDark
                                          ? 'Light Mode'
                                          : 'Dark Mode',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                        FontWeight.w600,
                                        color: primaryText,
                                      ),
                                    ),
                                  ),
                                  CupertinoSwitch(
                                    value: isDark,
                                    onChanged: (value) {
                                      ref
                                          .read(
                                        themeProvider.notifier,
                                      )
                                          .setTheme(
                                        value
                                            ? AppTheme.dark
                                            : AppTheme.light,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
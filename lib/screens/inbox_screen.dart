import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../models/email.dart';
import '../providers/email_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_service.dart';
import 'compose_screen.dart';
import 'email_details_screen.dart';
import 'settings_screen.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  int selectedIndex = 0;
  bool showInitialSkeleton = true;

  Timer? skeletonTimer;

  @override
  void initState() {
    super.initState();

    skeletonTimer = Timer(
      const Duration(seconds: 5),
          () {
        if (!mounted) {
          return;
        }

        setState(() {
          showInitialSkeleton = false;
        });
      },
    );
  }

  @override
  void dispose() {
    skeletonTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);
    final isDark = themeState.value == AppTheme.dark;

    return GlassScaffold(
      statusBarStyle: GlassStatusBarStyle.auto,
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? const [
              Color(0xFF101820),
              Color(0xFF18232D),
              Color(0xFF202D38),
            ]
                : const [
              Color(0xFFF3F7FA),
              Color(0xFFEAF1F6),
              Color(0xFFE2EBF2),
            ],
          ),
        ),
      ),
      body: _buildMainContent(isDark),
      bottomBar: GlassTabBar.bottom(
        selectedIndex: selectedIndex,
        onTabSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        tabs: const [
          GlassTab(
            icon: Icon(CupertinoIcons.tray_fill),
            label: 'Inbox',
          ),
          GlassTab(
            icon: Icon(CupertinoIcons.paperplane_fill),
            label: 'Sent',
          ),
          GlassTab(
            icon: Icon(CupertinoIcons.square_pencil),
            label: 'Compose',
          ),
          GlassTab(
            icon: Icon(CupertinoIcons.gear),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(bool isDark) {
    if (selectedIndex == 2) {
      return ComposeScreen(
        onEmailSent: () {
          setState(() {
            selectedIndex = 0;
          });
        },
      );
    }

    if (selectedIndex == 1) {
      return _buildSentScreen(isDark);
    }

    if (selectedIndex == 3) {
      return const SettingsScreen();
    }

    return Column(
      children: [
        _buildFixedHeader(isDark),
        Expanded(
          child: showInitialSkeleton
              ? _buildSkeletonList()
              : _buildInboxList(isDark),
        ),
      ],
    );
  }

  Widget _buildFixedHeader(bool isDark) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: Center(
          child: Text(
            'Inbox',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? const Color(0xFFF1F5F8)
                  : const Color(0xFF18232D),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSentScreen(bool isDark) {
    return FutureBuilder<List<Email>>(
      future: const ApiService().getSentEmails(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              _buildSentHeader(isDark),
              Expanded(
                child: _buildSkeletonList(),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return Column(
            children: [
              _buildSentHeader(isDark),
              Expanded(
                child: _buildErrorState(
                  snapshot.error.toString(),
                  isDark,
                ),
              ),
            ],
          );
        }

        final emails = snapshot.data ?? [];

        if (emails.isEmpty) {
          return Column(
            children: [
              _buildSentHeader(isDark),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.paperplane,
                        size: 48,
                        color: isDark
                            ? const Color(0xFF9BAAB5)
                            : const Color(0xFF71808C),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        'No sent emails',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFD5DEE5)
                              : const Color(0xFF4E5D6C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            _buildSentHeader(isDark),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      setState(() {});
                    },
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      4,
                      12,
                      120,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          return _SentEmailRow(
                            email: emails[index],
                            isDark: isDark,
                          );
                        },
                        childCount: emails.length,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSentHeader(bool isDark) {
    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: Center(
          child: Text(
            'Sent',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? const Color(0xFFF1F5F8)
                  : const Color(0xFF18232D),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return Skeletonizer(
      enabled: true,
      effect: const ShimmerEffect(
        duration: Duration(milliseconds: 1000),
      ),
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          12,
          8,
          12,
          120,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(
              bottom: 7,
            ),
            child: _SkeletonEmailCard(),
          );
        },
      ),
    );
  }

  Widget _buildInboxList(bool isDark) {
    final emailState = ref.watch(emailProvider);

    if (emailState.isLoading) {
      return _buildSkeletonList();
    }

    if (emailState.hasError) {
      return _buildErrorState(
        emailState.error.toString(),
        isDark,
      );
    }

    final emails = emailState.value ?? [];

    if (emails.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: [
        CupertinoSliverRefreshControl(
          onRefresh: () async {
            await ref
                .read(emailProvider.notifier)
                .refreshEmails();
          },
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            12,
            4,
            12,
            120,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return _EmailRow(
                  email: emails[index],
                  isDark: isDark,
                );
              },
              childCount: emails.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(
      String error,
      bool isDark,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassContainer(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle,
                  size: 44,
                  color: isDark
                      ? const Color(0xFF9BAAB5)
                      : const Color(0xFF71808C),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Unable to load emails',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFF1F5F8)
                        : const Color(0xFF26333E),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? const Color(0xFF9BAAB5)
                        : const Color(0xFF71808C),
                  ),
                ),
                const SizedBox(
                  height: 18,
                ),
                CupertinoButton(
                  color: isDark
                      ? const Color(0xFF2C3B47)
                      : const Color(0xFFDCE8F0),
                  borderRadius: BorderRadius.circular(16),
                  onPressed: () {
                    ref
                        .read(emailProvider.notifier)
                        .refreshEmails();
                  },
                  child: Text(
                    'Try Again',
                    style: TextStyle(
                      color: isDark
                          ? const Color(0xFFF1F5F8)
                          : const Color(0xFF35424D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.tray,
            size: 48,
            color: isDark
                ? const Color(0xFF9BAAB5)
                : const Color(0xFF71808C),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            'No emails',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? const Color(0xFFD5DEE5)
                  : const Color(0xFF4E5D6C),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmailRow extends StatelessWidget {
  final Email email;
  final bool isDark;

  const _EmailRow({
    required this.email,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = email.sender.isNotEmpty
        ? email.sender.substring(0, 1).toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 5,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) {
                return EmailDetailsScreen(
                  email: email,
                );
              },
            ),
          );
        },
        child: GlassContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _Avatar(
                  letter: firstLetter,
                  isUnread: !email.isRead,
                  isDark: isDark,
                ),
                const SizedBox(
                  width: 13,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              email.sender,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: email.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w700,
                                color: isDark
                                    ? const Color(0xFFF1F5F8)
                                    : const Color(0xFF18232D),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            _inboxDate(email.date),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: email.isRead
                                  ? FontWeight.w400
                                  : FontWeight.w600,
                              color: email.isRead
                                  ? (isDark
                                  ? const Color(0xFF9BAAB5)
                                  : const Color(0xFF74808B))
                                  : (isDark
                                  ? const Color(0xFFD5DEE5)
                                  : const Color(0xFF52606B)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        email.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: email.isRead
                              ? FontWeight.w500
                              : FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFD5DEE5)
                              : const Color(0xFF35424D),
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        email.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF9BAAB5)
                              : const Color(0xFF71808C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SentEmailRow extends StatelessWidget {
  final Email email;
  final bool isDark;

  const _SentEmailRow({
    required this.email,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = email.recipient.isNotEmpty
        ? email.recipient.substring(0, 1).toUpperCase()
        : '?';

    return Padding(
      padding: const EdgeInsets.only(
        bottom: 5,
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) {
                return EmailDetailsScreen(
                  email: email,
                );
              },
            ),
          );
        },
        child: GlassContainer(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.center,
              children: [
                _Avatar(
                  letter: firstLetter,
                  isUnread: false,
                  isDark: isDark,
                ),
                const SizedBox(
                  width: 13,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'To: ${email.recipient}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? const Color(0xFFF1F5F8)
                                    : const Color(0xFF18232D),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            _inboxDate(email.date),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? const Color(0xFF9BAAB5)
                                  : const Color(0xFF74808B),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        email.subject,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFFD5DEE5)
                              : const Color(0xFF35424D),
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        email.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFF9BAAB5)
                              : const Color(0xFF71808C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _inboxDate(String value) {
  final parsed = DateTime.tryParse(value);

  if (parsed == null) {
    return value;
  }

  final local = parsed.toLocal();
  final now = DateTime.now();

  final isToday = local.year == now.year &&
      local.month == now.month &&
      local.day == now.day;

  if (isToday) {
    return _formatInboxTime(local);
  }

  final yesterday = now.subtract(
    const Duration(days: 1),
  );

  final isYesterday =
      local.year == yesterday.year &&
          local.month == yesterday.month &&
          local.day == yesterday.day;

  if (isYesterday) {
    return 'Yesterday';
  }

  return '${_shortMonth(local.month)} ${local.day}';
}

String _formatInboxTime(DateTime date) {
  final hour = date.hour == 0
      ? 12
      : date.hour > 12
      ? date.hour - 12
      : date.hour;

  final minute = date.minute.toString().padLeft(
    2,
    '0',
  );

  final period = date.hour >= 12
      ? 'PM'
      : 'AM';

  return '$hour:$minute $period';
}

String _shortMonth(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  return months[month - 1];
}

class _Avatar extends StatelessWidget {
  final String letter;
  final bool isUnread;
  final bool isDark;

  const _Avatar({
    required this.letter,
    required this.isUnread,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF30414D)
                : const Color(0xFFD5E4EE),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            letter,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? const Color(0xFFDCE8F0)
                  : const Color(0xFF405260),
            ),
          ),
        ),
        if (isUnread)
          Positioned(
            right: -2,
            bottom: -1,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF4F91C8),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF18232D)
                      : const Color(0xFFEAF1F6),
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SkeletonEmailCard extends StatelessWidget {
  const _SkeletonEmailCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE3E8ED),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD7DEE4),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Bone.circle(
            size: 52,
          ),
          const SizedBox(
            width: 13,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Bone(
                      width: 135,
                      height: 14,
                    ),
                    Spacer(),
                    Bone(
                      width: 48,
                      height: 10,
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                Bone(
                  width: 185,
                  height: 12,
                ),
                SizedBox(
                  height: 7,
                ),
                Bone(
                  width: 235,
                  height: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
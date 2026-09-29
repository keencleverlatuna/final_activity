import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../models/email.dart';
import '../providers/email_provider.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  int selectedIndex = 0;

  final List<Email> demoEmails = const [
    Email(
      id: 1,
      sender: 'Professor Santos',
      recipient: 'student@school.com',
      subject: 'Assignment Reminder',
      message: 'Please submit your assignment before Monday.',
      date: '2:30 PM',
      isRead: false,
    ),
    Email(
      id: 2,
      sender: 'School Admin',
      recipient: 'student@school.com',
      subject: 'School Announcement',
      message: 'Please be reminded about the upcoming activity.',
      date: '10:15 AM',
      isRead: true,
    ),
    Email(
      id: 3,
      sender: 'Professor Cruz',
      recipient: 'student@school.com',
      subject: 'Laboratory Activity',
      message: 'Your laboratory activity has been posted.',
      date: 'Yesterday',
      isRead: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      statusBarStyle: GlassStatusBarStyle.auto,
      background: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4F8FC),
              Color(0xFFE7EEF5),
              Color(0xFFDDE6EF),
            ],
          ),
        ),
      ),
      appBar: GlassAppBar(
        title: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Text(
            _getTitle(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E2933),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              top: 10,
              right: 8,
            ),
            child: GlassIconButton(
              icon: const Icon(
                CupertinoIcons.refresh,
                size: 20,
              ),
              onPressed: () {
                ref.read(emailProvider.notifier).refreshEmails();
              },
            ),
          ),
        ],
      ),
      body: _buildBody(),
      bottomBar: GlassTabBar.bottom(
        selectedIndex: selectedIndex,
        onTabSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        tabs: const [
          GlassTab(
            icon: Icon(CupertinoIcons.tray),
            label: 'Inbox',
          ),
          GlassTab(
            icon: Icon(CupertinoIcons.paperplane),
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

  String _getTitle() {
    switch (selectedIndex) {
      case 1:
        return 'Sent';
      case 2:
        return 'Compose';
      case 3:
        return 'Settings';
      default:
        return 'Inbox';
    }
  }

  Widget _buildBody() {
    if (selectedIndex != 0) {
      return _buildPlaceholder();
    }

    final emailState = ref.watch(emailProvider);

    return emailState.when(
      loading: () {
        return _buildSkeletonList();
      },
      error: (error, stackTrace) {
        return _buildDemoInbox();
      },
      data: (emails) {
        if (emails.isEmpty) {
          return _buildEmptyInbox();
        }

        return _buildEmailList(emails);
      },
    );
  }

  Widget _buildSkeletonList() {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          18,
          34,
          18,
          120,
        ),
        itemCount: 5,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: _SkeletonEmailCard(),
          );
        },
      ),
    );
  }

  Widget _buildDemoInbox() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        18,
        34,
        18,
        120,
      ),
      itemCount: demoEmails.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _EmailCard(
            email: demoEmails[index],
          ),
        );
      },
    );
  }

  Widget _buildEmailList(List<Email> emails) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        18,
        34,
        18,
        120,
      ),
      itemCount: emails.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _EmailCard(
            email: emails[index],
          ),
        );
      },
    );
  }

  Widget _buildEmptyInbox() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.tray,
            size: 52,
            color: Color(0xFF6B7785),
          ),
          SizedBox(height: 16),
          Text(
            'No emails yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFF26333E),
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Your received emails will appear here.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF66717D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    String title;

    switch (selectedIndex) {
      case 1:
        title = 'Sent emails will appear here.';
        break;
      case 2:
        title = 'Compose screen coming next.';
        break;
      case 3:
        title = 'Settings screen coming next.';
        break;
      default:
        title = '';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getPlaceholderIcon(),
                  size: 48,
                  color: const Color(0xFF4E5D6C),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF26333E),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getPlaceholderIcon() {
    switch (selectedIndex) {
      case 1:
        return CupertinoIcons.paperplane;
      case 2:
        return CupertinoIcons.square_pencil;
      case 3:
        return CupertinoIcons.gear;
      default:
        return CupertinoIcons.tray;
    }
  }
}

class _EmailCard extends StatelessWidget {
  final Email email;

  const _EmailCard({
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter = email.sender.isNotEmpty
        ? email.sender.substring(0, 1).toUpperCase()
        : '?';

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFD9E5EF),
                borderRadius: BorderRadius.circular(26),
              ),
              alignment: Alignment.center,
              child: Text(
                firstLetter,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF3F4F5E),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: const Color(0xFF1E2933),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        email.date,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF65727E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    email.subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF26333E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    email.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      color: Color(0xFF66717D),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonEmailCard extends StatelessWidget {
  const _SkeletonEmailCard();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Bone.circle(
              size: 52,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.text(
                    words: 2,
                  ),
                  SizedBox(height: 9),
                  Bone.text(
                    words: 3,
                  ),
                  SizedBox(height: 8),
                  Bone.text(
                    words: 7,
                  ),
                  SizedBox(height: 8),
                  Bone(
                    width: 55,
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
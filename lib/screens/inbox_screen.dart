import 'package:flutter/widgets.dart';
import 'package:skeletonizer/skeletonizer.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  bool isLoading = true;

  final List<EmailPreview> emails = [
    EmailPreview(
      sender: 'Professor Santos',
      subject: 'Assignment Reminder',
      preview: 'Please submit your assignment before Monday.',
      time: '2:30 PM',
    ),
    EmailPreview(
      sender: 'School Admin',
      subject: 'School Announcement',
      preview: 'Please be reminded about the upcoming activity.',
      time: '10:15 AM',
    ),
    EmailPreview(
      sender: 'Professor Cruz',
      subject: 'Laboratory Activity',
      preview: 'Your laboratory activity has been posted.',
      time: 'Yesterday',
    ),
  ];

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: isLoading
          ? _buildLoadingList()
          : _buildEmailList(),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _EmailLoadingCard(),
        );
      },
    );
  }

  Widget _buildEmailList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      itemCount: emails.length,
      itemBuilder: (context, index) {
        final email = emails[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _EmailCard(
            email: email,
          ),
        );
      },
    );
  }
}

class _EmailLoadingCard extends StatelessWidget {
  const _EmailLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F5F8),
          borderRadius: BorderRadius.circular(26),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Bone.circle(
              size: 52,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone.text(
                    words: 2,
                  ),
                  SizedBox(height: 10),
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

class _EmailCard extends StatelessWidget {
  final EmailPreview email;

  const _EmailCard({
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F5F8),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFDDE4EB),
              borderRadius: BorderRadius.circular(26),
            ),
            alignment: Alignment.center,
            child: Text(
              email.sender.substring(0, 1),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      email.time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF68717D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  email.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email.preview,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF68717D),
                    height: 1.3,
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

class EmailPreview {
  final String sender;
  final String subject;
  final String preview;
  final String time;

  const EmailPreview({
    required this.sender,
    required this.subject,
    required this.preview,
    required this.time,
  });
}
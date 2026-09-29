import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../models/email.dart';
import '../providers/email_provider.dart';
import 'compose_screen.dart';

class EmailDetailsScreen extends ConsumerWidget {
  final Email email;

  const EmailDetailsScreen({
    super.key,
    required this.email,
  });

  Future<void> _deleteEmail(
      BuildContext context,
      WidgetRef ref,
      ) async {
    final shouldDelete = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return CupertinoAlertDialog(
          title: const Text(
            'Delete Email',
          ),
          content: const Padding(
            padding: EdgeInsets.only(
              top: 8,
            ),
            child: Text(
              'Are you sure you want to delete this email?',
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await ref
          .read(emailProvider.notifier)
          .deleteEmail(email.id);

      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      await showCupertinoDialog<void>(
        context: context,
        builder: (dialogContext) {
          return CupertinoAlertDialog(
            title: const Text(
              'Delete Failed',
            ),
            content: Padding(
              padding: const EdgeInsets.only(
                top: 8,
              ),
              child: Text(
                error.toString(),
              ),
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text(
                  'OK',
                ),
              ),
            ],
          );
        },
      );
    }
  }

  void _replyToEmail(BuildContext context) {
    final replySubject = email.subject.toLowerCase().startsWith('re:')
        ? email.subject
        : 'Re: ${email.subject}';

    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) {
          return ComposeScreen(
            replyRecipient: email.sender,
            replySubject: replySubject,
          );
        },
      ),
    );
  }

  @override
  Widget build(
      BuildContext context,
      WidgetRef ref,
      ) {
    return GlassScaffold(
      statusBarStyle: GlassStatusBarStyle.auto,
      background: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3F7FA),
              Color(0xFFEAF1F6),
              Color(0xFFE2EBF2),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  CupertinoButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      CupertinoIcons.back,
                      color: Color(0xFF18232D),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Email',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF18232D),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 52,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  14,
                  8,
                  14,
                  24,
                ),
                child: GlassContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          email.subject,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF18232D),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration:
                              const BoxDecoration(
                                color: Color(0xFFD5E4EE),
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                email.sender.isNotEmpty
                                    ? email.sender
                                    .substring(
                                  0,
                                  1,
                                )
                                    .toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight:
                                  FontWeight.w700,
                                  color:
                                  Color(0xFF405260),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 12,
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                                children: [
                                  Text(
                                    email.sender,
                                    style:
                                    const TextStyle(
                                      fontSize: 16,
                                      fontWeight:
                                      FontWeight.w700,
                                      color:
                                      Color(0xFF18232D),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    'To: ${email.recipient}',
                                    style:
                                    const TextStyle(
                                      fontSize: 13,
                                      color:
                                      Color(0xFF71808C),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    formatReceivedDate(
                                      email.date,
                                    ),
                                    style:
                                    const TextStyle(
                                      fontSize: 12,
                                      color:
                                      Color(0xFF71808C),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: const Color(
                            0xFFDCE3E8,
                          ),
                        ),
                        const SizedBox(
                          height: 24,
                        ),
                        Text(
                          email.message,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Color(0xFF26333E),
                          ),
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CupertinoButton(
                                padding:
                                const EdgeInsets
                                    .symmetric(
                                  vertical: 13,
                                ),
                                color: const Color(
                                  0xFFDCE8F0,
                                ),
                                borderRadius:
                                BorderRadius.circular(
                                  18,
                                ),
                                onPressed: () {
                                  _replyToEmail(
                                    context,
                                  );
                                },
                                child: const Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                                  children: [
                                    Icon(
                                      CupertinoIcons.reply,
                                      size: 18,
                                      color: Color(
                                        0xFF35424D,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 7,
                                    ),
                                    Text(
                                      'Reply',
                                      style: TextStyle(
                                        color: Color(
                                          0xFF35424D,
                                        ),
                                        fontWeight:
                                        FontWeight
                                            .w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            CupertinoButton(
                              padding:
                              const EdgeInsets
                                  .symmetric(
                                horizontal: 18,
                                vertical: 13,
                              ),
                              color: const Color(
                                0xFFE8DCDC,
                              ),
                              borderRadius:
                              BorderRadius.circular(
                                18,
                              ),
                              onPressed: () {
                                _deleteEmail(
                                  context,
                                  ref,
                                );
                              },
                              child: const Icon(
                                CupertinoIcons.trash,
                                size: 19,
                                color: Color(
                                  0xFF714848,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatReceivedDate(String value) {
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
    return 'Today, ${_formatTime(local)}';
  }

  final yesterday = now.subtract(
    const Duration(days: 1),
  );

  final isYesterday =
      local.year == yesterday.year &&
          local.month == yesterday.month &&
          local.day == yesterday.day;

  if (isYesterday) {
    return 'Yesterday, ${_formatTime(local)}';
  }

  return '${_monthName(local.month)} ${local.day}, ${local.year} • ${_formatTime(local)}';
}

String _formatTime(DateTime date) {
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

String _monthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  return months[month - 1];
}
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import '../providers/email_provider.dart';
import '../services/api_service.dart';

class ComposeScreen extends ConsumerStatefulWidget {
  final String? replyRecipient;
  final String? replySubject;
  final VoidCallback? onEmailSent;

  const ComposeScreen({
    super.key,
    this.replyRecipient,
    this.replySubject,
    this.onEmailSent,
  });

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final senderController = TextEditingController();
  final recipientController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();

  bool isSending = false;

  @override
  void initState() {
    super.initState();

    if (widget.replyRecipient != null) {
      recipientController.text = widget.replyRecipient!;
    }

    if (widget.replySubject != null) {
      subjectController.text = widget.replySubject!;
    }
  }

  @override
  void dispose() {
    senderController.dispose();
    recipientController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.dispose();
  }

  Future<void> sendEmail() async {
    final sender = senderController.text.trim();
    final recipient = recipientController.text.trim();
    final subject = subjectController.text.trim();
    final message = messageController.text.trim();

    if (sender.isEmpty ||
        recipient.isEmpty ||
        subject.isEmpty ||
        message.isEmpty) {
      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Incomplete'),
            content: const Text(
              'Please complete all fields before sending.',
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      await const ApiService().sendEmail(
        sender: sender,
        recipient: recipient,
        subject: subject,
        message: message,
      );

      await ref
          .read(emailProvider.notifier)
          .refreshEmails();

      if (!mounted) {
        return;
      }

      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Email Sent'),
            content: const Text(
              'Your email was sent successfully.',
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      if (!mounted) {
        return;
      }

      if (widget.onEmailSent != null) {
        widget.onEmailSent!();
      } else {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      await showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('Send Failed'),
            content: Text(error.toString()),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String placeholder,
    int minLines = 1,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return GlassContainer(
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: maxLines,
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: CupertinoColors.transparent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Compose'),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 10),
            const Text(
              'New Email',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            buildTextField(
              controller: senderController,
              placeholder: 'Your email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            buildTextField(
              controller: recipientController,
              placeholder: 'Recipient email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            buildTextField(
              controller: subjectController,
              placeholder: 'Subject',
            ),
            const SizedBox(height: 14),
            buildTextField(
              controller: messageController,
              placeholder: 'Write your message...',
              minLines: 8,
              maxLines: 12,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 24),
            GlassContainer(
              child: CupertinoButton.filled(
                onPressed: isSending ? null : sendEmail,
                child: isSending
                    ? const CupertinoActivityIndicator()
                    : const Text('Send Email'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
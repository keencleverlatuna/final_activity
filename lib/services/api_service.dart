import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/email.dart';

class ApiService {
  static const String baseUrl =
      'https://bisque-jellyfish-119892.hostingersite.com/school_mail_api';

  static const String myEmail =
      'keencleverlatuna19@gmail.com';

  const ApiService();

  Future<List<Email>> getEmails() async {
    final response = await http
        .get(
      Uri.parse('$baseUrl/emails.php'),
    )
        .timeout(
      const Duration(seconds: 10),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load emails. Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw Exception(
        'Invalid response from server.',
      );
    }

    if (decoded['success'] != true) {
      throw Exception(
        decoded['message']?.toString() ??
            'Failed to load emails.',
      );
    }

    final data = decoded['data'];

    if (data is! List) {
      throw Exception(
        'Invalid email data from server.',
      );
    }

    return data
        .map(
          (item) => Email.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  Future<List<Email>> getSentEmails() async {
    final emails = await getEmails();

    return emails
        .where(
          (email) =>
      email.sender.toLowerCase() ==
          myEmail.toLowerCase(),
    )
        .toList();
  }

  Future<void> sendEmail({
    required String sender,
    required String recipient,
    required String subject,
    required String message,
  }) async {
    final response = await http
        .post(
      Uri.parse('$baseUrl/send_email.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'sender': sender,
        'recipient': recipient,
        'subject': subject,
        'message': message,
      }),
    )
        .timeout(
      const Duration(seconds: 10),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to send email. Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic> &&
        decoded['success'] != true) {
      throw Exception(
        decoded['message']?.toString() ??
            'Failed to send email.',
      );
    }
  }

  Future<void> deleteEmail(int id) async {
    final response = await http
        .delete(
      Uri.parse('$baseUrl/delete_email.php?id=$id'),
    )
        .timeout(
      const Duration(seconds: 10),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete email. Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic> &&
        decoded['success'] != true) {
      throw Exception(
        decoded['message']?.toString() ??
            'Failed to delete email.',
      );
    }
  }

  Future<void> markAsRead(int id) async {
    final response = await http
        .post(
      Uri.parse('$baseUrl/mark_read.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'id': id,
      }),
    )
        .timeout(
      const Duration(seconds: 10),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to mark email as read. Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic> &&
        decoded['success'] != true) {
      throw Exception(
        decoded['message']?.toString() ??
            'Failed to mark email as read.',
      );
    }
  }
}
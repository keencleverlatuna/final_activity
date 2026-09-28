import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://YOUR-DOMAIN.com/api';

  Future<List<dynamic>> getEmails() async {
    final response = await http
        .get(
      Uri.parse('$baseUrl/emails.php'),
    )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load emails. Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      if (decoded['success'] == true) {
        return decoded['data'] ?? [];
      }

      throw Exception(
        decoded['message']?.toString() ?? 'Failed to load emails.',
      );
    }

    throw Exception('Invalid server response.');
  }

  Future<bool> deleteEmail(int id) async {
    final response = await http
        .post(
      Uri.parse('$baseUrl/emails.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'action': 'delete',
        'id': id,
      }),
    )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to delete email. Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded['success'] == true;
    }

    return false;
  }

  Future<bool> markAsRead(int id) async {
    final response = await http
        .post(
      Uri.parse('$baseUrl/emails.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'action': 'mark_read',
        'id': id,
      }),
    )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to update email. Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded['success'] == true;
    }

    return false;
  }

  Future<bool> sendEmail({
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
        'recipient': recipient,
        'subject': subject,
        'message': message,
      }),
    )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to send email. Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded['success'] == true;
    }

    return false;
  }

  Future<bool> replyToEmail({
    required int emailId,
    required String recipient,
    required String subject,
    required String message,
  }) async {
    final response = await http
        .post(
      Uri.parse('$baseUrl/reply_email.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email_id': emailId,
        'recipient': recipient,
        'subject': subject,
        'message': message,
      }),
    )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to send reply. Status code: ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return decoded['success'] == true;
    }

    return false;
  }
}
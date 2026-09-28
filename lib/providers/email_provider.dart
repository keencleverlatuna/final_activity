import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/email.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final emailProvider =
AsyncNotifierProvider<EmailNotifier, List<Email>>(
  EmailNotifier.new,
);

class EmailNotifier extends AsyncNotifier<List<Email>> {
  late final ApiService apiService;

  @override
  Future<List<Email>> build() async {
    apiService = ref.read(apiServiceProvider);

    final data = await apiService.getEmails();

    return data
        .map(
          (item) => Email.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  Future<void> refreshEmails() async {
    state = const AsyncLoading();

    try {
      final data = await apiService.getEmails();

      final emails = data
          .map(
            (item) => Email.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();

      state = AsyncData(emails);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> deleteEmail(int id) async {
    try {
      final success = await apiService.deleteEmail(id);

      if (!success) {
        throw Exception('Failed to delete email.');
      }

      final currentEmails = state.hasValue
          ? state.requireValue
          : <Email>[];

      state = AsyncData(
        currentEmails
            .where((email) => email.id != id)
            .toList(),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      final success = await apiService.markAsRead(id);

      if (!success) {
        throw Exception('Failed to mark email as read.');
      }

      final currentEmails = state.hasValue
          ? state.requireValue
          : <Email>[];

      state = AsyncData(
        currentEmails.map((email) {
          if (email.id == id) {
            return email.copyWith(isRead: true);
          }

          return email;
        }).toList(),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}
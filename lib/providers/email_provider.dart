import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/email.dart';
import '../services/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return const ApiService();
});

final emailProvider =
AsyncNotifierProvider<EmailNotifier, List<Email>>(
  EmailNotifier.new,
);

class EmailNotifier extends AsyncNotifier<List<Email>> {
  @override
  Future<List<Email>> build() async {
    final apiService = ref.read(apiServiceProvider);

    return apiService.getEmails();
  }

  Future<void> refreshEmails() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final apiService = ref.read(apiServiceProvider);

      return apiService.getEmails();
    });
  }

  Future<void> deleteEmail(int id) async {
    final apiService = ref.read(apiServiceProvider);

    try {
      await apiService.deleteEmail(id);

      final currentEmails = state.value ?? [];

      state = AsyncData(
        currentEmails
            .where(
              (email) => email.id != id,
        )
            .toList(),
      );
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );
    }
  }

  Future<void> markAsRead(int id) async {
    final apiService = ref.read(apiServiceProvider);

    try {
      await apiService.markAsRead(id);

      final currentEmails = state.value ?? [];

      state = AsyncData(
        currentEmails.map((email) {
          if (email.id == id) {
            return email.copyWith(
              isRead: true,
            );
          }

          return email;
        }).toList(),
      );
    } catch (error, stackTrace) {
      state = AsyncError(
        error,
        stackTrace,
      );
    }
  }
}
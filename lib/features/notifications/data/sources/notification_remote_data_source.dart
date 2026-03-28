import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/error_mapper.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<NotificationModel>> streamNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<void> insertNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SupabaseClient _client;

  NotificationRemoteDataSourceImpl({required SupabaseClient client})
      : _client = client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Stream<List<NotificationModel>> streamNotifications() {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((e) => NotificationModel.fromJson(e)).toList());
  }

  @override
  Future<void> markAsRead(String id) async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('id', id)
          .eq('user_id', _userId);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<void> markAllAsRead() async {
    try {
      await _client
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', _userId)
          .eq('is_read', false);
    } catch (e) {
      throw ErrorMapper.fromError(e);
    }
  }

  @override
  Future<void> insertNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      await _client.from('notifications').insert({
        'user_id': userId,
        'title': title,
        'body': body,
        'type': type,
        'is_read': false,
      });
    } catch (e) {
      // Fire-and-forget: don't surface notification insert failures to the user
      debugPrint('[NotificationDataSource] insertNotification failed: $e');
    }
  }
}

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

final notiServiceProvider = Provider<NotiService>((ref) {
  return NotiService();
});

class NotiService {
  final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<bool> _requestPermissions() async {
    if (Platform.isIOS) {
      return await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    } else if (Platform.isAndroid) {
      final androidPlugin = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.requestNotificationsPermission() ?? true;
    }
    return true;
  }

  Future<void> initNotification() async {
    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettingsIos = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIos,
    );

    // Initialize the plugin
    final initialized = await _notificationsPlugin.initialize(initSettings);
    if (initialized == null || !initialized) {
      print('Failed to initialize notifications');
    }

    // Request permissions
    final permissionGranted = await _requestPermissions();
    if (!permissionGranted) {
      print('Notification permissions not granted');
    }
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notifications',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    try {
      await _notificationsPlugin.show(
        id,
        title,
        body,
        _notificationDetails(),
      );
      print('Notification shown successfully: $title');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}
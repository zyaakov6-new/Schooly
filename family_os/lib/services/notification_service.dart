import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../utils/constants.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await _createChannels();
    _configureFcm();
  }

  Future<void> _createChannels() async {
    const dailyChannel = AndroidNotificationChannel(
      AppConstants.channelDailyId,
      'Daily Summary',
      description: 'Daily family summary notifications',
      importance: Importance.defaultImportance,
    );

    const reminderChannel = AndroidNotificationChannel(
      AppConstants.channelReminderId,
      'Reminders',
      description: 'Task and event reminders',
      importance: Importance.high,
    );

    const taskChannel = AndroidNotificationChannel(
      AppConstants.channelTaskId,
      'Tasks',
      description: 'Task notifications',
      importance: Importance.defaultImportance,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(dailyChannel);
    await androidPlugin?.createNotificationChannel(reminderChannel);
    await androidPlugin?.createNotificationChannel(taskChannel);
  }

  void _configureFcm() {
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification != null) {
        showNotification(
          title: notification.title ?? 'FamilyOS',
          body: notification.body ?? '',
          channelId: AppConstants.channelReminderId,
        );
      }
    });
  }

  Future<bool> requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String channelId = AppConstants.channelReminderId,
    int id = 0,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelId,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      _toTZDateTime(scheduledDate),
      NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.channelReminderId,
          'Reminders',
          importance: Importance.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelNotification(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();

  // Stub – in production use timezone package
  dynamic _toTZDateTime(DateTime dateTime) => dateTime;
}

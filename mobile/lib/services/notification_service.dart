import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';
import '../main.dart';
import '../pages/reminder_list_page.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

   const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
  requestAlertPermission: true,
  requestBadgePermission: true,
  requestSoundPermission: true,
  defaultPresentAlert: true,
  defaultPresentBadge: true,
  defaultPresentSound: true,
);

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

  await _notifications.initialize(
  settings,
  onDidReceiveNotificationResponse: (NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    _openReminderPageFromPayload(payload);
  },
);

final launchDetails =
    await _notifications.getNotificationAppLaunchDetails();

final launchPayload =
    launchDetails?.notificationResponse?.payload;

if (launchPayload != null) {
  Future.delayed(const Duration(milliseconds: 700), () {
    _openReminderPageFromPayload(launchPayload);
  });
}
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(
        'medication_channel',
        'İlaç Hatırlatmaları',
        description: 'İlaç bildirimleri',
        importance: Importance.max,
      ),
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static void _openReminderPageFromPayload(String payload) {
  if (!payload.startsWith("reminders:")) return;

  final userIdText = payload.split(":")[1];
  final userId = int.tryParse(userIdText);

  if (userId == null) return;

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (_) => ReminderListPage(userId: userId),
    ),
  );
}

  static NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'medication_channel',
        'İlaç Hatırlatmaları',
        channelDescription: 'İlaç içme zamanı hatırlatmaları',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  static Future<void> showTestNotification() async {
    await _notifications.show(
      999,
      "Test Bildirimi",
      "Bildirim sistemi çalışıyor",
      _notificationDetails(),
    );
  }

  static Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required int userId,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: "reminders:$userId",
    );
  }

static Future<void> scheduleWeeklyNotification({
  required int id,
  required String title,
  required String body,
  required int hour,
  required int minute,
  required int userId,
}) async {
  await _notifications.zonedSchedule(
    id,
    title,
    body,
    _nextInstanceOfTime(hour, minute),
    _notificationDetails(),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    payload: "reminders:$userId",
  );
}
  static Future<void> scheduleOnceNotification({
    required int id,
    required String title,
    required String body,
    required int hour,
    required int minute,
    required int userId,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfTime(hour, minute),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: "reminders:$userId",
    );
  }

static Future<void> scheduleNotificationAt({
  required int id,
  required String title,
  required String body,
  required DateTime dateTime,
}) async {
  await _notifications.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(dateTime, tz.local),
    _notificationDetails(),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  );
}
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
static Future<void> cancelAllNotifications() async {
  await _notifications.cancelAll();
}


  static Future<void> scheduleGlucoseWarningNotification({
  required int id,
  required String title,
  required String body,
  required DateTime dateTime,
}) async {
  await _notifications.zonedSchedule(
    id,
    title,
    body,
    tz.TZDateTime.from(dateTime, tz.local),
    _notificationDetails(),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  );
}


}
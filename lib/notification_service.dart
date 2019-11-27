import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:tododo/todo_service.dart';

class NotificationService {
  static Future<NotificationService> init() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        new FlutterLocalNotificationsPlugin();

    var initializationSettingsAndroid =
        new AndroidInitializationSettings('app_icon');

    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {});

    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onSelectNotification: (String payload) async {
        if (payload != null) {
          debugPrint('notification payload: ' + payload);
        }
      },
    );

    return NotificationService._(flutterLocalNotificationsPlugin);
  }

  NotificationService._(this.flutterLocalNotification);
  final FlutterLocalNotificationsPlugin flutterLocalNotification;

  void scheduleNofication(TodoItem todo) {
    var notifID = (todo.reminderDate.difference(DateTime(2019)).inSeconds);

    flutterLocalNotification.schedule(
      notifID,
      'You have a ToDoDo',
      todo.text,
      todo.reminderDate.subtract(
        Duration(minutes: 2),
      ),
      NotificationDetails(
        AndroidNotificationDetails(
            'ToDoReminder', 'ToDoReminder', 'This is a todo reminder channel',
            sound: 'inflicted', importance: Importance.High),
        IOSNotificationDetails(),
      ),
    );
  }

  Future<void> modifyScheduledNotificationFor(
    int index,
    TodoItem newTodoItem,
    TodoItem oldTodoItem,
  ) async {
    var pendingNotifications =
        await flutterLocalNotification.pendingNotificationRequests();

    var idOfOldNotification = pendingNotifications.indexWhere(
      (x) =>
          x.id ==
          oldTodoItem.reminderDate.millisecondsSinceEpoch -
              DateTime(2019).millisecondsSinceEpoch,
    );

    await flutterLocalNotification.cancel(idOfOldNotification);
    scheduleNofication(newTodoItem);
  }
}

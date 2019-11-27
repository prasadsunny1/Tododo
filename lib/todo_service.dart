import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart' as pp;
import 'package:path/path.dart' as p;
import 'package:tododo/notification_service.dart';

@immutable
class TodoItem {
  const TodoItem({
    this.text,
    this.inFlight,
    this.reminderDate,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      text: json['text'] as String,
      inFlight: json['inFlight'] as bool,
      reminderDate: DateTime.parse(json["reminderDate"]),
    );
  }

  final String text;
  final bool inFlight;
  final DateTime reminderDate;

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'inFlight': inFlight,
      'reminderDate': reminderDate.toIso8601String(),
    };
  }

  TodoItem copyWith({
    String text,
    bool inFlight,
    DateTime reminderDate,
  }) {
    return TodoItem(
      text: text ?? this.text,
      inFlight: inFlight ?? this.inFlight,
      reminderDate: reminderDate ?? this.reminderDate,
    );
  }
}

///Interface to achive polymophism
///to be able to swap out different DB implementations effortlessly
abstract class TodoServiceBase {
  List<TodoItem> get todoList;
  // CRUD
  Stream<TodoItem> createTodo(String title, {DateTime reminderDate});
  Stream<TodoItem> readTodo(int index);
  Stream<TodoItem> updateTodo(int index, String title, {DateTime reminderDate});
  Stream<TodoItem> deleteTodo(int index);
}

class TodoServiceFile implements TodoServiceBase {
  static Future<TodoServiceFile> init(
      NotificationService localNotificationService) async {
    final dir = await pp.getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'todo.json'));
    List<TodoItem> todos = [];
    if (await file.exists()) {
      final List<dynamic> data = json.decode(await file.readAsString());
      todos = data
          .cast<Map<String, dynamic>>()
          .map((item) => TodoItem.fromJson(item))
          .toList();
    }
    return TodoServiceFile._(file, todos, localNotificationService);
  }

  TodoServiceFile._(
      this._todoFile, this._todoList, this.localNotificationService);
  final NotificationService localNotificationService;

  File _todoFile;
  List<TodoItem> _todoList;

  @override
  List<TodoItem> get todoList => _todoList;

  @override
  Stream<TodoItem> createTodo(String title, {DateTime reminderDate}) async* {
    final todoItem =
        TodoItem(text: title, inFlight: true, reminderDate: reminderDate);
    _todoList.add(todoItem);
    yield todoItem;
    try {
      await persistTodos();
    } finally {
      final index = _todoList.indexOf(todoItem);
      _todoList[index] = todoItem.copyWith(inFlight: false);
      await persistTodos();
      yield _todoList[index];
      localNotificationService.scheduleNofication(todoItem);
    }
  }

  @override
  Stream<TodoItem> readTodo(int index) {
    return Stream.value(_todoList[index]);
  }

  @override
  Stream<TodoItem> updateTodo(int index, String title,
      {DateTime reminderDate}) async* {
    final item = _todoList[index].copyWith(
        text: title, inFlight: true, reminderDate: reminderDate ?? null);
    _todoList[index] = item;
    yield item;
    try {
      await persistTodos();
    } finally {
      final index = _todoList.indexOf(item);
      _todoList[index] = item.copyWith(inFlight: false);
      yield _todoList[index];
      var oldTodoItem = todoList[index];
      await localNotificationService.modifyScheduledNotificationFor(
          index, item, oldTodoItem);
    }
  }

  @override
  Stream<TodoItem> deleteTodo(int index) {
    final item = _todoList.removeAt(index);
    persistTodos();
    return Stream.value(item);
  }

  Future<void> persistTodos() async {
    await Future.delayed(const Duration(seconds: 2));
    _todoFile.writeAsString(json.encode(_todoList));
  }
}

class TodoServiceNonPersistant implements TodoServiceBase {
  @override
  final List<TodoItem> todoList = <TodoItem>[];

  @override
  Stream<TodoItem> createTodo(String title, {DateTime reminderDate}) {
    final item =
        TodoItem(text: title, inFlight: false, reminderDate: reminderDate);
    todoList.add(item);
    return Stream.value(item);
  }

  @override
  Stream<TodoItem> readTodo(int index) {
    return Stream.value(todoList[index]);
  }

  @override
  Stream<TodoItem> updateTodo(int index, String title,
      {DateTime reminderDate}) {
    return Stream.value(todoList[index] =
        todoList[index].copyWith(text: title, reminderDate: reminderDate));
  }

  @override
  Stream<TodoItem> deleteTodo(int index) {
    return Stream.value(todoList.removeAt(index));
  }
}

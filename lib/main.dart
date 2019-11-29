import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:provider/provider.dart';
import 'package:tododo/settings_page.dart';
import 'package:tododo/settings_bloc.dart';
import 'package:tododo/settings_service.dart';
import 'package:tododo/todo_bloc.dart';
import 'package:tododo/todo_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'notification_service.dart';

Future<void> main() async {
  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
//  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  WidgetsFlutterBinding.ensureInitialized();
  NotificationService notificationService = await NotificationService.init();
  final todoService = await TodoServiceFile.init(notificationService);
  final settingService = await SettingsService.init();

  runZoned<Future<void>>(() async {
    runApp(
      MultiProvider(
        providers: [
          Provider<SettingsBloc>.value(value: SettingsBloc(settingService)),
          Provider<TodoBloc>.value(value: TodoBloc(todoService)),
        ],
        child: MyApp(),
      ),
    );
  }, onError: Crashlytics.instance.recordError);
}

@immutable
class MyApp extends StatelessWidget {
  const MyApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TodoBloc todoBloc = Provider.of<TodoBloc>(context);
    final SettingsBloc settingsBloc = Provider.of<SettingsBloc>(context);
    return StreamBuilder<AppTheme>(
        initialData: settingsBloc.currentTheme,
        stream: settingsBloc.themeStream,
        builder: (context, snapshot) {
          ThemeData theme;
          switch (snapshot.data) {
            case AppTheme.Light:
              theme = ThemeData(primarySwatch: Colors.blue);
              break;
            case AppTheme.Dark:
              theme = ThemeData(
                  primarySwatch: Colors.blue, brightness: Brightness.dark);
              break;
            case AppTheme.Note:
              theme = ThemeData(
                  primarySwatch: Colors.amber, brightness: Brightness.light);
              break;
          }
          FirebaseAnalytics analytics = FirebaseAnalytics();

          return MaterialApp(
            title: 'Flutter Todo',
            theme: theme,
            navigatorObservers: [
              FirebaseAnalyticsObserver(analytics: analytics),
            ],
            home: MyHomePage(
              title: 'ToDoDO',
              todoBloc: todoBloc,
            ),
          );
        });
  }
}

@immutable
class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key key,
    @required this.title,
    @required this.todoBloc,
  }) : super(key: key);

  final String title;
  final TodoBloc todoBloc;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textFieldController = TextEditingController();

  void _deleteTodo(BuildContext context, int index) {
    _displayDeleteWarning(context, index);
  }

  void _createTodo(BuildContext context) {
    _displayAddTodoDialog(context);
  }

  void _editTodo(BuildContext context, int index) async {
    var currentTodoItem = await widget.todoBloc.getTodoAt(index);
    await _displayAddTodoDialog(
      context,
      isUpdate: true,
      currentTodoItem: currentTodoItem,
      updateIndex: index,
    );
  }

  Future<void> _displayAddTodoDialog(
    BuildContext context, {
    bool isUpdate = false,
    TodoItem currentTodoItem,
    int updateIndex,
  }) async {
    if (isUpdate) _textFieldController.text = currentTodoItem.text;
    return await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return CreateTodoAlertDialog(
            bloc: widget.todoBloc,
            isUpdate: isUpdate,
            updateIndex: updateIndex,
            currentTodoItem: currentTodoItem);
      },
    );
  }

  Future<void> _displayDeleteWarning(
      BuildContext context, int deleteIndex) async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm deletion'),
          actions: <Widget>[
            new FlatButton(
              child: new Text('CANCEL'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text('DELETE'),
              onPressed: () {
                widget.todoBloc.deleteTodo(deleteIndex);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              //navigate to settings page
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SettingsPage(),
                ),
              );
            },
          )
        ],
      ),
      body: StreamBuilder<List<TodoItem>>(
        initialData: widget.todoBloc.todoList,
        stream: widget.todoBloc.todoListStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<TodoItem>> snapshot) {
          if (snapshot.hasData) {
            var todoList = snapshot.data;
            return ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (BuildContext context, int index) {
                final item = todoList[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(item.text),
                    subtitle: Text(
                        '${item.reminderDate.day}-${item.reminderDate.month} ${item.reminderDate.hour}:${item.reminderDate.minute} '),
                    leading: Icon(Icons.event),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        if (item.inFlight)
                          const SizedBox(
                            width: kMinInteractiveDimension,
                            height: kMinInteractiveDimension,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            //Delete this item
                            _editTodo(context, index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            //Delete this item
                            _deleteTodo(context, index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createTodo(context);
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

class CreateTodoAlertDialog extends StatefulWidget {
  final int updateIndex;

  CreateTodoAlertDialog({
    Key key,
    this.bloc,
    this.isUpdate,
    this.updateIndex,
    this.currentTodoItem,
  }) : super(key: key);
  final TodoBloc bloc;
  final bool isUpdate;
  final TodoItem currentTodoItem;

  @override
  _CreateTodoAlertDialogState createState() =>
      _CreateTodoAlertDialogState(currentTodoItem: currentTodoItem);
}

class _CreateTodoAlertDialogState extends State<CreateTodoAlertDialog> {
  final TextEditingController _textFieldController = TextEditingController();
  TodoItem currentTodoItem;
  var dateTime = DateTime.now();

  _CreateTodoAlertDialogState({TodoItem currentTodoItem}) {
    if (currentTodoItem != null) {
      currentTodoItem = currentTodoItem;
      _textFieldController.text = currentTodoItem.text;
      dateTime = currentTodoItem.reminderDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add a Todo'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: _textFieldController,
            decoration: InputDecoration(hintText: "Input some text"),
          ),
          Row(
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.access_time),
                onPressed: () {
                  DatePicker.showDateTimePicker(
                    context,
                    currentTime: currentTodoItem?.reminderDate,
                    minTime: DateTime.now(),
                    onConfirm: (date) {
                      print('confirm $date');
                      setState(() {
                        dateTime = date;
                      });
                    },
                  );
                },
              ),
              Text(
                '${dateTime.day} - ${dateTime.month} | ${dateTime.hour}:${dateTime.minute}',
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        new FlatButton(
          child: new Text('CANCEL'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        new FlatButton(
          child: new Text('SAVE'),
          onPressed: () {
            if (widget.isUpdate) {
              widget.bloc.updateTodo(
                _textFieldController.text,
                widget.updateIndex,
                reminderDate: dateTime ?? null,
              );
            } else {
              widget.bloc.createTodo(
                _textFieldController.text,
                reminderDate: dateTime ?? null,
              );
            }
            _textFieldController.clear();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

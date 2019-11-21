import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:tododo/todo_bloc.dart';
import 'package:tododo/todo_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final service = await TodoServiceFile.init();
  runApp(MyApp(bloc: TodoBloc(service)));
}

@immutable
class MyApp extends StatelessWidget {
  const MyApp({
    Key key,
    @required this.bloc,
  }) : super(key: key);

  final TodoBloc bloc;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'ToDoDO',
        bloc: bloc,
      ),
    );
  }
}

@immutable
class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key key,
    @required this.title,
    @required this.bloc,
  }) : super(key: key);

  final String title;
  final TodoBloc bloc;

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
    //open dialog with title filled
    //save on save
    var currentTitle = await widget.bloc.getTodoAt(index);
    await _displayAddTodoDialog(
      context,
      isUpdate: true,
      prefillTitle: currentTitle.text,
      updateIndex: index,
    );
  }

  Future<void> _displayAddTodoDialog(
    BuildContext context, {
    bool isUpdate = false,
    String prefillTitle,
    int updateIndex,
  }) async {
    if (isUpdate) _textFieldController.text = prefillTitle;
    return await showDialog<DateTime>(
      context: context,
      builder: (context) {
        return CreateTodoAlertDialog(
          bloc: widget.bloc,
          isUpdate: isUpdate,
          updateIndex: updateIndex,
        );
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
                widget.bloc.deleteTodo(deleteIndex);
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
      appBar: AppBar(title: Text(widget.title)),
      body: StreamBuilder<List<TodoItem>>(
        initialData: widget.bloc.todoList,
        stream: widget.bloc.todoListStream,
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
  }) : super(key: key);
  final TodoBloc bloc;
  final bool isUpdate;
  @override
  _CreateTodoAlertDialogState createState() => _CreateTodoAlertDialogState();
}

class _CreateTodoAlertDialogState extends State<CreateTodoAlertDialog> {
  final TextEditingController _textFieldController = TextEditingController();

  var dateTime = DateTime.now();

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
                  DatePicker.showDateTimePicker(context, onConfirm: (date) {
                    print('confirm $date');
                    setState(() {
                      dateTime = date;
                    });
                  });
                },
              ),
              Text('${dateTime.year} - ${dateTime.month} - ${dateTime.day}'),
            ],
          )
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

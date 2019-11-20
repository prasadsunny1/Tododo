import 'package:flutter/material.dart';
import 'package:tododo/todo_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final TodoBloc bloc = new TodoBloc();
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

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key, this.title, this.bloc}) : super(key: key);
  final String title;
  final TodoBloc bloc;

  TextEditingController _textFieldController = TextEditingController();

  void _deleteTodo(BuildContext context, int index) {
    _displayDeleteWarning(context, index);
  }

  void _createTodo(BuildContext context) {
    _displayAddTodoDialog(context);
  }

  _displayAddTodoDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add a Todo'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Input some text"),
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
                  bloc.createTodo(_textFieldController.text);
                  _textFieldController.clear();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  _displayDeleteWarning(BuildContext context, int deleteIndex) async {
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
                  bloc.deleteTodo(deleteIndex);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: []),
      body: StreamBuilder(
        stream: bloc.todoListStream,
        initialData: bloc.todos,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var todoList = snapshot.data;
            return ListView.builder(
              itemCount: todoList.length,
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  // subtitle: Text("Detail"),
                  title: Text(todoList[index]),
                  leading: Icon(Icons.event),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      //Delete this item
                      _deleteTodo(context, index);
                    },
                  ),
                ),
              ),
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

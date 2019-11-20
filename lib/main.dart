import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final List<String> allTodos = ['Pick up milk', 'Call John Wick'];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Todo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'ToDoDO',
        todos: allTodos,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.todos}) : super(key: key);
  final String title;
  final List<String> todos;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _textFieldController = TextEditingController();

  void _deleteTodo(int index) {
    setState(() {
      _displayDeleteWarning(context, index);
    });
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
                  setState(() {
                    widget.todos.add(_textFieldController.text);
                  });
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
                  setState(() {
                    widget.todos.removeAt(deleteIndex);
                  });
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
      appBar: AppBar(title: Text(widget.title), actions: []),
      body: ListView.builder(
        itemCount: widget.todos.length,
        itemBuilder: (context, index) => Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            // subtitle: Text("Detail"),
            title: Text(widget.todos[index]),
            leading: Icon(Icons.event),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                //Delete this item
                _deleteTodo(index);
              },
            ),
          ),
        ),
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

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final List<String> allTodos = ['todo1', 'todo2'];
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
  int _counter = 0;
  TextEditingController _textFieldController = TextEditingController();

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void _deleteTodo(int index) {
    setState(() {
      widget.todos.removeAt(index);
    });
  }

  void _createTodo(BuildContext context) {
//open dialog with textfield
    _displayDialog(context);
// save on submit
  }

  _displayDialog(BuildContext context) async {
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
      appBar: AppBar(title: Text(widget.title), actions: [
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () {
            _createTodo(context);
          },
        )
      ]),
      body: ListView.builder(
        itemCount: widget.todos.length,
        itemBuilder: (context, index) => ListTile(
          // subtitle: Text("Detail"),
          title: Text(widget.todos[index]),
          leading: Icon(Icons.fingerprint),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              //Delete this item
              _deleteTodo(index);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}

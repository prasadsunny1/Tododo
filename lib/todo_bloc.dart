//bloc is just a way to manage state
//or say it just helps you beautifully connect UI with your buisness logic
// It is desirable to keep bloc and buisness logic in different files to avoid mess
import 'dart:async';

class TodoBloc {
  TodoBloc();
  final List<String> todos = <String>[];

  final StreamController<List<String>> _todoListController =
      StreamController<List<String>>();
      
  Stream<List<String>> get todoListStream => _todoListController.stream;

  void deleteTodo(int index) {
    //just delete
    todos.removeAt(index);
    _todoListController.sink.add(todos);
  }

  void dispose() {
    _todoListController.close();
  }

  void createTodo(String title) {
    todos.add(title);
    _todoListController.sink.add(todos);
  }
}

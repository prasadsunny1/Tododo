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
//Logic to retrive process and sink the updated values of todos
  void _refreshStream() {
    _todoListController.sink.add(todos);
  }

  void dispose() {
    _todoListController.close();
  }

  void createTodo(String title) {
    if (title.isEmpty) return;
    todos.add(title);
    _refreshStream();
  }

  void updateTodo(String title, int updateIndex) {
    todos[updateIndex] = title;
    _refreshStream();
  }

  void deleteTodo(int index) {
    //just delete
    todos.removeAt(index);
    _refreshStream();
  }

  String getTodoAt(int index) {
    return todos[index];
  }
}

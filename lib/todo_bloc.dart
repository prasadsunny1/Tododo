//bloc is just a way to manage state
//or say it just helps you beautifully connect UI with your buisness logic
// It is desirable to keep bloc and buisness logic in different files to avoid mess
import 'dart:async';

import 'package:tododo/todo_service.dart';

class TodoBloc {
  TodoBloc();
  TodoServiceBase _todoService = new TodoServiceNonPersistant();

  final StreamController<List<String>> _todoListController =
      StreamController<List<String>>();

  Stream<List<String>> get todoListStream => _todoListController.stream;
//Logic to retrive process and sink the updated values of todos
  void _refreshStream() {
    var allTodos = _todoService.getAllTodos();
    _todoListController.sink.add(allTodos);
  }

  void dispose() {
    _todoListController.close();
  }

  void createTodo(String title) {
    if (title.isEmpty) return;
    _todoService.createTodo(title);
    _refreshStream();
  }

  void updateTodo(String title, int updateIndex) {
    _todoService.updateTodo(title, updateIndex);
    _refreshStream();
  }

  void deleteTodo(int index) {
    _todoService.deleteTodo(index);
    _refreshStream();
  }

  String getTodoAt(int index) {
    return _todoService.getTodoAt(index);
  }

  List<String> getAllTodos() {
    return _todoService.getAllTodos();
  }
}

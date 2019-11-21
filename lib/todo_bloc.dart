//bloc is just a way to manage state
//or say it just helps you beautifully connect UI with your buisness logic
// It is desirable to keep bloc and buisness logic in different files to avoid mess
import 'dart:async';

import 'package:tododo/todo_service.dart';

class TodoBloc {
  TodoBloc(this._todoService);
  
  TodoServiceBase _todoService;
  final _todoListController = StreamController<List<TodoItem>>.broadcast();

  List<TodoItem> get todoList => _todoService.todoList;
  Stream<List<TodoItem>> get todoListStream => _todoListController.stream;

  // Logic to retrive process and sink the updated values of todos
  void _updateStream() {
    _todoListController.sink.add(_todoService.todoList);
  }

  void dispose() {
    _todoListController.close();
  }

  void createTodo(String title) {
    if (title.isEmpty) return;
    _todoService.createTodo(title).forEach((item){
      _updateStream();
    });
  }

  Future<TodoItem> getTodoAt(int index) {
    return _todoService.readTodo(index).first;
  }

  void updateTodo(String title, int updateIndex) {
    _todoService.updateTodo(updateIndex, title).forEach((item){
      _updateStream();
    });
  }

  void deleteTodo(int index) {
    _todoService.deleteTodo(index).forEach((item){
      _updateStream();
    });
  }
}

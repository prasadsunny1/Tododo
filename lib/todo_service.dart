///Interface to achive polymophism
///to be able to swap out different DB implementations effortlessly
abstract class TodoServiceBase {
  void createTodo(String title);
  void updateTodo(String title, int updateIndex);
  void deleteTodo(int index);
  List<String>  getAllTodos();
  String getTodoAt(int index);
}

class TodoServiceSharedPref implements TodoServiceBase {
  @override
  void createTodo(String title) {
    // TODO: implement createTodo
  }

  @override
  void deleteTodo(int index) {
    // TODO: implement deleteTodo
  }

  @override
  List<String> getAllTodos() {
    // TODO: implement getAllTodos
    return null;
  }

  @override
  String getTodoAt(int index) {
    // TODO: implement getTodoAt
    return null;
  }

  @override
  void updateTodo(String title, int updateIndex) {
    // TODO: implement updateTodo
  }
  
}

class TodoServiceNonPersistant implements TodoServiceBase {
  final List<String> todos = <String>[];
  @override
  void createTodo(String title) {
    todos.add(title);
  }

  @override
  void deleteTodo(int index) {
    todos.removeAt(index);
  }

  @override
  List<String> getAllTodos() {
    return todos;
  }

  @override
  String getTodoAt(int index) {
    return todos[index];
  }

  @override
  void updateTodo(String title, int updateIndex) {
    todos[updateIndex] = title;
  }
}

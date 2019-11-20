///Interface to achive polymophism
///to be able to swap out different DB implementations effortlessly
abstract class TodoServiceBase {
  void createToDo();
  void deleteToDo();
}

class TodoService implements TodoServiceBase {
  @override
  void createToDo() {
    // TODO: implement _createToDo
  }

  @override
  void deleteToDo() {
    // TODO: implement _deleteToDo
  }
}

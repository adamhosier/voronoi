class DLL<T> {

  DLLNode first, last;

  void add(T value) {
    DLLNode newNode = new DLLNode(value);

    if(first == null) {
      first = newNode;
    } else {
      DLLNode current = first;

      while(current.hasNext) {
        current = current.next;
      }

      current.next = newNode;
      newNode.prev = current;
    }
  }

  List<T> toList() {
    List<T> l = new List();

    DLLNode current = first;
    while(current != null) {
      l.add(current.value);
      current = current.next;
    }

    return l;
  }

  String toString() {
    return toList().toString();
  }

}

class DLLNode<T> {
  DLLNode next, prev;
  T value;

  DLLNode(this.value);

  bool get hasNext => next != null;
  bool get hasPrev => prev != null;
}
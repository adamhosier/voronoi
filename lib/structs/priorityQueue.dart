class PriorityQueue<E extends Comparable> {

  List<E> data = new List<E>();

  bool get isEmpty {
    return data.isEmpty;
  }

  bool get isNotEmpty {
    return !isEmpty;
  }

  void clear() {
    data = new List<E>();
  }

  void pushAll (Iterable<E> iterable) {
    iterable.forEach(this.push);
  }

  void push(Object value) {
    if(!(value is Comparable))
      throw new ArgumentError("Priority queue requires comparable types");
    try {
      data.add(value);
      _bubbleUp(data.length - 1);
    } catch(_) {
      throw new ArgumentError("Prioriy queue requires consistent value types");
    }
  }

  E get peek => isEmpty ? null : data[0];

  E get pop {
    if(isEmpty) return null;

    E val = peek;

    data[0] = data.last;
    data.removeLast();
    _bubbleDown(0);

    return val;
  }

  void _bubbleUp(int child) {
    if(child != 0) {
      int parent = _parent(child);
      if(data[child].compareTo(data[parent]) > 0) {
        _swap(child, parent);
        _bubbleUp(parent);
      }
    }
  }

  void _bubbleDown(int root) {
    if(!_isLeaf(root)) {
      // select greatest child
      int child = _leftChild(root);
      if(_hasRightChild(root)) {
        if(data[child + 1].compareTo(data[child]) > 0) {
          child++;
        }
      }

      // swap if required
      if(data[root].compareTo(data[child]) < 0) {
        _swap(root, child);
        _bubbleDown(child);
      }
    }
  }

  void _swap(int i, int j) {
    E tmp = data[j];
    data[j] = data[i];
    data[i] = tmp;
  }

  bool _isLeaf(int i) => !_hasLeftChild(i);
  bool _hasLeftChild(int i) => data.length >= 2 * i + 2;
  bool _hasRightChild(int i) => data.length >= 2 * i + 3;

  int _leftChild(int i) => 2 * i + 1;
  int _rightChild(int i) => 2 * i + 2;
  int _parent(int i) => (i - 1) ~/ 2;

  List<E> toList() {
    List l = new List();
    while(isNotEmpty) l.insert(0, pop);
    return l;
  }

  String toString() {
    return "Priority Queue " + data.toString();
  }

}
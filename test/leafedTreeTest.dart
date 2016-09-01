import 'package:test/test.dart';
import 'package:vor/structs/leafedTree.dart';
import 'dart:math';

main() {

  group("Queue size", () {
    test("Newly created tree is empty", () {
      LeafedTree q = new LeafedTree();
      expect(q.isEmpty, isTrue);
      expect(q.isNotEmpty, isFalse);
    });

    test("Populated queue is not empty", () {
      LeafedTree q = new LeafedTree();
      q.root = new TestLeaf(0.0);
      expect(q.isEmpty, isFalse);
      expect(q.isNotEmpty, isTrue);
    });

    test("Cleared list is empty", () {
      LeafedTree q = new LeafedTree();
      q.root = new TestLeaf(0.0);
      q.clear();
      expect(q.isEmpty, isTrue);
    });
  });

  group("Functionality", () {

  });

  group("Error checking", () {

  });
}

class TestInternalNode extends TreeInternalNode {
  double val;
  TestInternalNode(this.val);
}
class TestLeaf extends TreeLeaf {
  double val;
  TestLeaf(this.val);
}
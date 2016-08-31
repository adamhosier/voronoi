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
      q.root = new TestLeaf();
      expect(q.isEmpty, isFalse);
      expect(q.isNotEmpty, isTrue);
    });

    test("Cleared list is empty", () {
      LeafedTree q = new LeafedTree();
      q.root = new TestLeaf();
      q.clear();
      expect(q.isEmpty, isTrue);
    });
  });

  group("Functionality", () {

  });

  group("Error checking", () {

  });
}

class TestInternalNode extends TreeInternalNode {}
class TestLeaf extends TreeLeaf {}
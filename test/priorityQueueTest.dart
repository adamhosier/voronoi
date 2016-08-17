import 'package:test/test.dart';
import 'package:vor/structs/priorityQueue.dart';
import 'dart:math';

main() {
  group("Queue size", () {
    test("Newly created queue is empty", () {
      PriorityQueue q = new PriorityQueue();
      expect(q.isEmpty, isTrue);
      expect(q.isNotEmpty, isFalse);
    });

    test("Populated queue is not empty", () {
      PriorityQueue q = new PriorityQueue();
      q.push(3);
      expect(q.isEmpty, isFalse);
      expect(q.isNotEmpty, isTrue);
    });

    test("Cleared list is empty", () {
      PriorityQueue q = new PriorityQueue();
      q.push(3);
      q.clear();
      expect(q.isEmpty, isTrue);
    });

    test("Queue with single element is empty after popping", () {
      PriorityQueue q = new PriorityQueue();
      q.push(3);
      q.pop;
      expect(q.isEmpty, isTrue);
    });
  });

  group("Functionality", () {
    test("Queue with single element contains it at the front", () {
      PriorityQueue q = new PriorityQueue();
      q.push(3);
      expect(q.peek, equals(3));
    });

    test("Queue with multiple elements pops them in order", () {
      PriorityQueue q = new PriorityQueue();
      q.pushAll([5,8,2,3,9,6,1,4,0,7]);
      for(int i = 9; i >= 0; i--) {
        expect(q.pop, equals(i));
      }
    });

    test("Queue with a large number of elements pops them in order", () {
      const int NUM_ELEMS = 10000;
      const int MAX_NUM = 1000000;
      PriorityQueue q = new PriorityQueue();
      Random rng = new Random();
      List random_nums = new List.generate(NUM_ELEMS, (_) => rng.nextInt(MAX_NUM));
      q.pushAll(random_nums);

      random_nums.sort();
      for(int n in random_nums.reversed) {
        expect(q.pop, equals(n));
      }
    });

    test("Peeking at an empty queue returns null", () {
      PriorityQueue q = new PriorityQueue();
      expect(q.peek, isNull);
    });

    test("Popping from an empty queue returns null", () {
      PriorityQueue q = new PriorityQueue();
      expect(q.pop, isNull);
    });

    test("Item can be pushed after queue is cleared", () {
      PriorityQueue q = new PriorityQueue();
      q.push(3);
      q.clear();
      q.push(1);
      expect(q.pop, equals(1));
    });

    test("Queue can be converted to a sorted list", () {
      PriorityQueue q = new PriorityQueue();
      q.pushAll([5,6,1,3,2,4]);
      expect(q.toList(), equals([1,2,3,4,5,6]));
    });

    test("Queue can handle multiple similar values", () {
      PriorityQueue q = new PriorityQueue();
      q.pushAll([4,0,3,2,3,0,3,0,1,4]);
      expect(q.toList(), equals([0,0,0,1,2,3,3,3,4,4]));
    });
  });

  group("Error checking", () {
    test("Pushing a non-comparable type throws an error", () {
      PriorityQueue q = new PriorityQueue();
      expect(() => q.push(true), throwsArgumentError);
    });

    test("Pushing two different types throws an error", () {
      PriorityQueue q = new PriorityQueue();
      q.push(3);
      expect(() => q.push('2'), throwsArgumentError);
    });
  });
}
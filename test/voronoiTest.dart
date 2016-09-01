import 'package:test/test.dart';
import 'package:vor/voronoi/voronoi.dart';
import 'package:vor/geometry/geometry.dart';
import 'dart:math';

main() {
  group("Structure", () {
    test("Number of faces is the same as the number of sites", () {
      List<Vector2> pts = [new Vector2(100.0, 100.0), new Vector2(105.0, 200.0), new Vector2(150.0, 130.0), new Vector2(85.0, 287.0), new Vector2(153.0, 321.0)];
      Voronoi v = new Voronoi(pts, new Rectangle(0.0,0.0,500.0,500.0));
      expect(v.faces.length, equals(pts.length));
    });

    test("All edges form a loop", () {
      List<Vector2> pts = [new Vector2(100.0, 100.0), new Vector2(105.0, 200.0), new Vector2(150.0, 130.0), new Vector2(85.0, 287.0), new Vector2(153.0, 321.0)];
      Voronoi v = new Voronoi(pts, new Rectangle(0.0,0.0,500.0,500.0));
      for (HalfEdge e in v.edges) {
        HalfEdge next = e.next;
        while(next != null && next != e) {
          next = next.next;
        }
        expect(next, isNotNull);
        expect(next, equals(e));
      }
    });
  });

  group("Edge cases", () {
    test("No input points throws an error", () {
      expect(() => new Voronoi([], new Rectangle(0.0, 0.0, 200.0, 200.0)), throwsArgumentError);
    });

    test("A single point produces one face", () {
      List<Vector2> pts = [new Vector2(100.0, 100.0)];
      Voronoi v = new Voronoi(pts, new Rectangle(0.0, 0.0, 200.0, 200.0));
      expect(v.faces.length, equals(1));
    });
  });

  group("Error checking", () {
    test("Creating diagram with no input sites throws an error", () {
      expect(() => new Voronoi([], new Rectangle(0.0,0.0,500.0,500.0)), throwsArgumentError);
    });
  });
}
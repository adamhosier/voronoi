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

    test("Each face has an associated edge", () {
      List<Vector2> pts = [new Vector2(100.0, 100.0), new Vector2(105.0, 200.0), new Vector2(150.0, 130.0), new Vector2(85.0, 287.0), new Vector2(153.0, 321.0)];
      Voronoi v = new Voronoi(pts, new Rectangle(0.0,0.0,500.0,500.0));
      v.faces.forEach((Face f) {
        expect(f.edge, isNotNull);
      });
    });

    test("All edges form a loop", () {
      List<Vector2> pts = [new Vector2(100.0, 100.0), new Vector2(310.0, 412.0), new Vector2(105.0, 200.0), new Vector2(150.0, 130.0), new Vector2(85.0, 287.0), new Vector2(153.0, 321.0)];
      Voronoi v = new Voronoi(pts, new Rectangle(0.0,0.0,500.0,500.0));
      v.edges.forEach((HalfEdge e) {
        HalfEdge next = e.next;
        while(next != null && next != e) {
          next = next.next;
        }
        expect(next, isNotNull);
        expect(next, equals(e));
      });
    });

    test("Each edge has an associated face", () {
      List<Vector2> pts = [new Vector2(432.0, 86.0), new Vector2(100.0, 100.0), new Vector2(310.0, 412.0), new Vector2(105.0, 200.0), new Vector2(150.0, 130.0), new Vector2(85.0, 287.0), new Vector2(153.0, 321.0)];
      Voronoi v = new Voronoi(pts, new Rectangle(0.0,0.0,500.0,500.0));
      v.edges.forEach((HalfEdge e) {
        expect(e.face, isNotNull);
      });
    });

    test("Each edge loop has the same associated face", () {
      List<Vector2> pts = [new Vector2(432.0, 86.0), new Vector2(100.0, 100.0), new Vector2(12.2, 99.3), new Vector2(310.0, 412.0), new Vector2(105.0, 200.0), new Vector2(150.0, 130.0), new Vector2(85.0, 287.0), new Vector2(153.0, 321.0)];
      Voronoi v = new Voronoi(pts, new Rectangle(0.0,0.0,500.0,500.0));
      v.faces.forEach((Face f) {
        HalfEdge start = f.edge;
        HalfEdge curr = start;
        do {
          expect(curr.face, equals(start.face));
          curr = curr.next;
        } while(curr != start);
      });
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
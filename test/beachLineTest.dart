import 'package:vor/voronoi/voronoi.dart';
import 'package:test/test.dart';
import 'package:vor/geometry/geometry.dart';

main() {
  test("Tree is initially empty", () {
    BeachLine t = new BeachLine();
    expect(t.isEmpty, true);
    expect(t.isNotEmpty, false);
  });

  test("Tree with node added is nonempty", () {
    BeachLine t = new BeachLine();
    t.root = new BSTLeaf(new VoronoiSite(Vector2.Zero));
    expect(t.isEmpty, false);
    expect(t.isNotEmpty, true);
  });
}
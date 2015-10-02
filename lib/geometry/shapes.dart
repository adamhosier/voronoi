part of geometry;

class Circle {
  Vector2 o;
  double r;

  double get x => o.x;
  double get y => o.y;

  double get bottom => o.y + r;

  Circle(this.o, this.r);

  Circle.fromPoints(Vector2 p1, Vector2 p2, Vector2 p3) {
    // find midpoint
    double m1 = (p1.x - p2.x) / (p2.y - p1.y); // negative reciprocal of line p1p2
    Vector2 mid1 = new Vector2((p1.x + p2.x) / 2, (p1.y + p2.y) / 2); //midpoint p1p2

    double m2 = (p1.x - p3.x) / (p3.y - p1.y); // same for line p1p3
    Vector2 mid2 = new Vector2((p1.x + p3.x) / 2, (p1.y + p3.y) / 2);

    // solve for x and y
    double ox = (mid2.y - mid1.y + m1 * mid1.x - m2 * mid2.x) / (m1 - m2);
    double oy = m1 * (ox - mid1.x) + mid1.y;

    this.o = new Vector2(ox, oy);
    this.r = (p1 - this.o).magnitude;
  }

  String toString() {
    return "Circle at $o with radius $r";
  }

}
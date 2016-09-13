part of geometry;

class Vector2 {
  double x, y;

  static Vector2 Zero = new Vector2(0.0,0.0);

  Vector2(this.x, this.y);
  Vector2.fromPoint(Point p) {
    this.x = p.x;
    this.y = p.y;
  }

  Vector2 operator +(Object other) => other is Vector2 ? new Vector2(x + other.x, y + other.y) : new Vector2(x + other, y + other);
  Vector2 operator -(Object other) => other is Vector2 ? new Vector2(x - other.x, y - other.y) : new Vector2(x + other, y + other);
  Vector2 operator *(double amt) => new Vector2(x * amt, y * amt);
  Vector2 operator /(double amt) => new Vector2(x / amt, y / amt);

  double get magnitude => sqrt(x * x + y * y);
  Point get asPoint => new Point(x, y);

  distanceTo(Vector2 other) {
    return (this - other).magnitude;
  }

  String toString() {
    return "($x, $y)";
  }

  operator ==(Object other) => (other is Vector2 && other.x == x && other.y == y) || (other is Point && other.x == x && other.y == y);
  int get hashCode => x.hashCode + y.hashCode;
}

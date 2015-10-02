part of geometry;

class Vector2 {
  double x, y;

  Vector2(this.x, this.y);

  Vector2 operator +(Vector2 other) => new Vector2(x + other.x, y + other.y);
  Vector2 operator -(Vector2 other) => new Vector2(x - other.x, y - other.y);
  Vector2 operator *(double amt) => new Vector2(x * amt, y * amt);
  Vector2 operator /(double amt) => new Vector2(x / amt, y / amt);

  double get magnitude => sqrt(x * x + y * y);

  String toString() {
    return "($x, $y)";
  }
}

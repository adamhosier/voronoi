part of geometry;

class Line {
  Point p1, p2;

  Line(this.p1, this.p2);
}

class Parabola {
  double a, b, c;

  double f(double x) {
    return a * x * x + b * x + c;
  }

  List<Vector2> intersections(Parabola other) {
    List<Vector2> solution = new List();

    double sa = a - other.a;
    double sb = b - other.b;
    double sc = c - other.c;

    double desc = sb*sb - 4 * sa * sc;

    if(desc == 0) {
      double x = -sb / (2 * sa);
      solution.add(new Vector2(x, f(x)));
    } else if(desc > 0) {
      double x1 = (-sb + sqrt(desc)) / (2 * sa);
      double x2 = (-sb - sqrt(desc)) / (2 * sa);

      solution.add(new Vector2(x1, f(x1)));
      solution.add(new Vector2(x2, f(x2)));
    }

    return solution;
  }
}


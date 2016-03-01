part of sampler;

class UniformSampler extends Sampler {

  UniformSampler(Rectangle r) : super(r);
  UniformSampler.withRng(Rectangle r, Random rng) : super.withRng(r, rng);

  Vector2 generatePoint() {
    return new Vector2(rect.left + _rng.nextDouble() * rect.width, rect.top + _rng.nextDouble() * rect.height);
  }

  List<Vector2> generatePoints(int numPoints) {
    List<Vector2> ps = new List();
    for(int i = 0; i < numPoints; i++) {
      ps.add(generatePoint());
    }
    return ps;
  }

  Vector2 generateAnnulusPoint(Vector2 o, double r) {
    double angle = _rng.nextDouble() * 2 * PI;
    double length = _rng.nextDouble() * r + r;
    return new Vector2(o.x + length * sin(angle), o.y + length * cos(angle));
  }
}
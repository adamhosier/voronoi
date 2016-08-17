part of sampler;

class JitteredGridSampler extends Sampler {

  JitteredGridSampler(Rectangle r) : super(r);

  List<Vector2> generatePoints(int numPoints) {
    List<Vector2> ps = new List();

    // length/width of each grid square
    double boxSize = sqrt((_rect.width * _rect.height) / numPoints);

    // number of boxes on the width/height of the space
    int boxCols = _rect.width ~/ boxSize;
    int boxRows = (numPoints / boxCols).round();

    // add random sample in each grid cell
    for(int i = 0; i < boxRows; i++) {
      for(int j = 0; j < boxCols; j++) {
        UniformSampler s = new UniformSampler.withRng(
            new Rectangle(_rect.left + j * boxSize, _rect.top + i * boxSize, boxSize, boxSize), _rng);
        ps.add(s.generatePoint());
      }
    }
    return ps;
  }
}
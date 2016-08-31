part of sampler;

class PoissonDiskSampler extends Sampler {

  UniformSampler us;

  set rng(Random rng) {
    us = new UniformSampler.withRng(_rect, rng);
    rng = rng;
  }

  PoissonDiskSampler(Rectangle r) : super(r) {
    us = new UniformSampler.withRng(r, _rng);
  }

  PoissonDiskSampler.withRng(Rectangle r, Random rng) : super.withRng(r, rng) {
    us = new UniformSampler.withRng(r, rng);
  }

  List<Vector2> _generatePoints(double r, int k) {
    // number of boxes on the width/height of the space
    double boxSize = r / sqrt(2);
    int boxCols = (_rect.width / boxSize).ceil();
    int boxRows = (_rect.height / boxSize).ceil();

    // grid of active samples
    List<List<Vector2>> grid = new List();
    for(int i = 0; i < boxCols; i++) grid.add(new List(boxRows));

    // active/processing points
    List<Vector2> active = new List();

    // output points
    List<Vector2> ps = new List();

    // starting point
    Vector2 pt = us.generatePoint();
    ps.add(pt);
    active.add(pt);
    grid[(pt.x - _rect.left) ~/ boxSize][(pt.y - _rect.top) ~/ boxSize] = pt;

    // loop until nothing new to add
    while(active.isNotEmpty) {
      Vector2 target = active[_rng.nextInt(active.length)];
      int i;
      for(i = 0; i < k; i++) {
        Vector2 candidate = us.generateAnnulusPoint(target, r);

        // get grid indices
        int gridX = (candidate.x - _rect.left) ~/ boxSize;
        int gridY = (candidate.y - _rect.top) ~/ boxSize;

        // checks if a gridX and gridY can be inserted
        bool isValidSpace(Vector2 candidate, int gridX, int gridY) {
          // neighbour grid squares
          for(int i = max(0, gridX - 1); i < min(gridX + 2, boxCols); i++) {
            for(int j = max(0, gridY - 1); j < min(gridY + 2, boxRows); j++) {
              if(grid[i][j] != null && grid[i][j].distanceTo(candidate) < r) return false;
            }
          }
          return true;
        }

        //check if candidate is valid
        bool valid = gridX >= 0 && gridX < boxCols && gridY >= 0 && gridY < boxRows && isValidSpace(candidate, gridX, gridY);

        if(valid) {
          ps.add(candidate);
          active.add(candidate);
          grid[gridX][gridY] = candidate;
          break;
        }
      }
      if(i == k) active.remove(target);
    }
    return ps;
  }

  List<Vector2> generatePoints(num numPoints, [k = 30]) {
    if(numPoints <= 0) return [];
    return _generatePoints(sqrt((_rect.width * _rect.height) / numPoints)*0.82 + 150 / numPoints, k);
  }
}
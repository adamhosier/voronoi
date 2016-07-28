part of sampler;

class PoissonDiskSampler extends Sampler {

  UniformSampler us;

  PoissonDiskSampler(Rectangle r) : super(r) {
    us = new UniformSampler.withRng(r, _rng);
  }

  List<Vector2> generatePoints(num numPoints, [k = 20]) {
    // output points
    List<Vector2> ps = new List();

    if(numPoints <= 0) return ps;

    // active/processing points
    List<Vector2> active = new List();

    // length/width of each grid square
    numPoints = numPoints * 5.1;
    double boxSize = sqrt((rect.width * rect.height) / numPoints);

    // number of boxes on the width/height of the space
    int boxCols = rect.width ~/ boxSize;
    int boxRows = (numPoints / boxCols).ceil();

    // inner radius of the disk
    double r = boxSize * 2 * PI;

    // grid of active sampels
    List<List<Vector2>> grid = new List();
    for(int i = 0; i < boxCols; i++) grid.add(new List(boxRows));

    // starting point
    Vector2 pt = us.generatePoint();
    ps.add(pt);
    active.add(pt);
    grid[(pt.x - rect.left) ~/ boxSize][(pt.y - rect.top) ~/ boxSize] = pt;

    // loop until nothing new to add
    while(active.isNotEmpty) {
      Vector2 target = active[_rng.nextInt(active.length)];
      int i;
      for(i = 0; i < k; i++) {
        Vector2 candidate = us.generateAnnulusPoint(target, r);

        // get grid indices
        int gridX = (candidate.x - rect.left) ~/ boxSize;
        int gridY = (candidate.y - rect.top) ~/ boxSize;

        // checks if a gridX and gridY can be inserted
        bool isValidSpace(gridX, gridY) {
          // neighbour grid coords
          int iStart = max(0, gridX - 1);
          int jStart = max(0, gridY - 1);
          int iEnd = min(gridX + 2, boxCols);
          int jEnd = min(gridY + 2, boxRows);

          for(int i = iStart; i < iEnd; i++) {
            for(int j = jStart; j < jEnd; j++) {
              if(grid[i][j] != null) return false;
            }
          }
          return true;
        }

        //check if candidate is valid
        bool valid = gridX >= 0 && gridX < boxCols && gridY >= 0 && gridY < boxRows && isValidSpace(gridX, gridY);

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
}
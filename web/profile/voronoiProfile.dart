import "package:vor/voronoi/voronoi.dart";
import "package:vor/sampler/sampler.dart";
import "dart:math";

main() {
  Rectangle box = new Rectangle(0.0, 0.0, 10000.0, 10000.0); // large bounding box

  int NUM_PTS = 5000;
  int NUM_RUNS = 20;

  int startTime = new DateTime.now().millisecondsSinceEpoch;
  for(int i = 0; i < NUM_RUNS; i++) {
    Voronoi v = new Voronoi(new UniformSampler(box).generatePoints(NUM_PTS), box);
  }
  int time = new DateTime.now().millisecondsSinceEpoch - startTime;

  print("${NUM_RUNS} Voronoi(s) with ${NUM_PTS} points took ${time / 1000} seconds to generate");
}
library sampler;

import 'package:vor/geometry/geometry.dart';
import 'dart:math';

part "uniformSampler.dart";
part "poissonDiskSampler.dart";
part "jitteredGridSampler.dart";

abstract class Sampler {

  Random _rng;
  Rectangle rect;

  Sampler(this.rect) {
    _rng = new Random();
  }

  Sampler.withRng(this.rect, this._rng);

  set rng(Random rng) => _rng = rng;
  set seed(int seed) => _rng = new Random(seed);

  List<Vector2> generatePoints(int numPoints);
}
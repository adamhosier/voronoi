library sampler;

import 'package:vor/geometry/geometry.dart';
import 'dart:math';

part "uniformSampler.dart";
part "poissonDiskSampler.dart";
part "jitteredGridSampler.dart";

abstract class Sampler {

  Random _rng;
  Rectangle _rect;

  Sampler(this._rect) {
    _rng = new Random();
  }

  Sampler.withRng(this._rect, this._rng);

  set rng(Random rng) => _rng = rng;
  set seed(int seed) => _rng = new Random(seed);

  List<Vector2> generatePoints(int numPoints);
}
import "dart:html";
import "dart:math";
import "package:vor/geometry/geometry.dart";
import "package:vor/voronoi/voronoi.dart";
import 'package:vor/sampler/sampler.dart';

CanvasElement c;
CanvasRenderingContext2D ctx;
Voronoi v;
Random rng = new Random();

int NUM_POINTS = 500;

main() {
  c = document.getElementById("draw");
  ctx = c.getContext("2d");

  c.width = window.innerWidth;
  c.height = window.innerHeight;

  // create bounding box
  int padding = 50;
  Rectangle box = new Rectangle(padding, padding, c.width - 2*padding, c.height - 2*padding);

  // randomly generate points
  List<Vector2> sites = new PoissonDiskSampler(box).generatePoints(NUM_POINTS);

  // compute and draw voronoi
  v = new Voronoi(sites, box);
  draw(v);
}


draw(Voronoi v) {
  ctx.clearRect(0, 0, c.width, c.height);

  //sites
  ctx.fillStyle = "#000";
  ctx.strokeStyle = "#DDD";
  v.sites.forEach((Vector2 p) {
    ctx.beginPath();
    ctx.arc(p.x, p.y, 1.5, 0, 2 * PI);
    ctx.fill();
  });

  // faces
  ctx.strokeStyle = "#00F";
  v.faces.forEach((Face f) {
    HalfEdge start = f.edge;
    HalfEdge curr = start;

    do {
      Vector2 begin, end;
      double amt = 1.8;
      Vector2 diffs = f.center - curr.start;
      Vector2 diffe = f.center - curr.end;
      begin = f.center - diffs * ((diffs.magnitude - amt) / diffs.magnitude);
      end = f.center - diffe * ((diffe.magnitude - amt) / diffe.magnitude);

      ctx.beginPath();
      ctx.moveTo(begin.x, begin.y);
      ctx.lineTo(end.x, end.y);
      ctx.stroke();
      curr = curr?.next;
    } while(curr != null && curr != start);
  });
}
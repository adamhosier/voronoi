import "dart:html";
import "dart:math";
import "package:vor/geometry/geometry.dart";
import "package:vor/voronoi/voronoi.dart";
import 'package:vor/sampler/sampler.dart';

CanvasElement c;
CanvasRenderingContext2D ctx;
Voronoi v;
Random rng = new Random();

int NUM_POINTS = 20;

Rectangle box;

main() {
  c = document.getElementById("draw");
  ctx = c.getContext("2d");

  c.width = window.innerWidth;
  c.height = window.innerHeight;
  int padding = 50;
  box = new Rectangle(padding, padding, c.width - 2*padding, c.height - 2*padding);

  // generate initial voronoi
  List<Vector2> pts = new PoissonDiskSampler(box).generatePoints(NUM_POINTS);
  v = new Voronoi(pts, box);
  draw(v, Vector2.Zero);

  // update on mouse move
  window.onMouseMove.listen((MouseEvent e) {
    Vector2 mousepos = new Vector2.fromPoint(e.offset);
    v = new Voronoi(new List.from(pts)..add(mousepos), box);
    draw(v, mousepos);
  });
}

draw(Voronoi v, Vector2 mousepos) {
  ctx.clearRect(0, 0, c.width, c.height);

  //sites
  ctx.fillStyle = "#000";
  v.sites.forEach((Vector2 p) {
    ctx.beginPath();
    ctx.arc(p.x, p.y, 1.5, 0, 2 * PI);
    ctx.fill();
  });

  //faces
  ctx.strokeStyle = "#007";
  v.faces.forEach((Face f) {
    HalfEdge start = f.edge;
    HalfEdge curr = start;
    do {
      double amt = 1.8;
      Vector2 diffs = f.center - curr.start;
      Vector2 diffe = f.center - curr.end;
      Vector2 start = f.center - diffs * ((diffs.magnitude - amt) / diffs.magnitude);
      Vector2 end = f.center - diffe * ((diffe.magnitude - amt) / diffe.magnitude);

      ctx.beginPath();
      ctx.moveTo(start.x, start.y);
      ctx.lineTo(end.x, end.y);
      ctx.stroke();
      curr = curr?.next;
    } while(curr != null && curr != start);
  });

}
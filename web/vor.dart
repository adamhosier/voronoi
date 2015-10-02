library map;

import "dart:html";
import "dart:math";
import "package:vor/geometry/geometry.dart";
import "package:vor/structs/dll.dart";
import "package:vor/voronoi/voronoi.dart";

CanvasElement c;
CanvasRenderingContext2D ctx;
Voronoi v;
DLL d;

main() {
  d = new DLL();
  c = document.getElementById("draw");
  ctx = c.getContext("2d");

  c.width = window.innerWidth;
  c.height = window.innerHeight;

  int NUM_POINTS = 4;
  v = new Voronoi(getPoints(NUM_POINTS), c.getBoundingClientRect(), start:false);
  draw(v);

  window.onKeyDown.listen((KeyboardEvent e) {
    if(e.keyCode == 32) {
      v.nextEvent();
      if(v.q.isNotEmpty) draw(v);
    }
  });

}

List<Vector2> getPoints(int amt, [int seed]) {
  return [new Vector2(500.0, 500.0), new Vector2(450.0, 550.0), new Vector2(525.0, 575.0), new Vector2(460.0, 650.0)];
  /*List<Vector2> pts = new List();
  Random rng = new Random(seed);

  for(int i = 0; i < amt; i++) {
    pts.add(new Vector2(rng.nextDouble() * c.width, rng.nextDouble() * c.height));
  }

  return pts;*/
}

draw(Voronoi v) {
  ctx.clearRect(0, 0, c.width, c.height);

  //sites
  ctx.fillStyle = "#000";
  v.sites.forEach((Vector2 p) {
    ctx.beginPath();
    ctx.arc(p.x, p.y, 2, 0, 2*PI);
    ctx.fill();

    if(p.y < v.sweep) {
      double xdist = sqrt(v.sweep * v.sweep - p.y * p.y);
      ctx.beginPath();
      ctx.moveTo(p.x - xdist, 0);
      ctx.quadraticCurveTo(p.x, p.y + v.sweep, p.x + xdist, 0);
      ctx.stroke();
    }
  });

  //sweep line
  ctx.strokeStyle = "#F00";
  ctx.beginPath();
  ctx.moveTo(0, v.sweep);
  ctx.lineTo(c.width, v.sweep);
  ctx.stroke();
}
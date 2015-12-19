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
Random rng = new Random();

main() {
  d = new DLL();
  c = document.getElementById("draw");
  ctx = c.getContext("2d");

  c.width = window.innerWidth;
  c.height = window.innerHeight;

  int NUM_POINTS = 6;
  v = new Voronoi(getPoints(NUM_POINTS, 1232), c.getBoundingClientRect(), start:false);
  draw(v);

  window.onKeyDown.listen((KeyboardEvent e) {
    if(e.keyCode == 32) {
      if(v.q.isNotEmpty) {
        v.nextEvent();
        draw(v);
      }
    }
  });

}

List<Vector2> getPoints(int amt, [int seed]) {
  //return [new Vector2(500.0, 500.0), new Vector2(450.0, 550.0), new Vector2(525.0, 575.0), new Vector2(460.0, 650.0), new Vector2(600.0, 660.0)];
  List<Vector2> pts = new List();
  Random rng = new Random(seed);

  Rectangle b = new Rectangle(200, 200, 400, 400);
  for(int i = 0; i < amt; i++) {
    pts.add(new Vector2(b.left + rng.nextDouble() * b.width, b.top + rng.nextDouble() * b.height));
  }

  return pts;
}

draw(Voronoi v) {
  ctx.clearRect(0, 0, c.width, c.height);

  //circles
  ctx.strokeStyle = "#ACA";
  ctx.lineWidth = 1;
  v.circles.forEach((Circle c) {
    ctx.beginPath();
    ctx.arc(c.x, c.y, c.r, 0, 2*PI);
    ctx.stroke();
  });

  //sites
  ctx.fillStyle = "#000";
  ctx.strokeStyle = "#DDD";
  v.sites.forEach((Vector2 p) {
    ctx.beginPath();
    ctx.arc(p.x, p.y, 2, 0, 2*PI);
    ctx.fill();

    //arcs
    if(p.y <= v.sweep) {
      double xdist = sqrt(v.sweep * v.sweep - p.y * p.y);
      ctx.beginPath();
      ctx.moveTo(p.x - xdist, 0);
      ctx.quadraticCurveTo(p.x, p.y + v.sweep, p.x + xdist, 0);
      ctx.stroke();
    }
  });

  //beach line intersections
  ctx.strokeStyle = "#F00";
  print("");
  v.beachBreakpoints.forEach((Vector2 p) {
    print(p);
    ctx.beginPath();
    ctx.arc(p.x, p.y, 5, 0, 2*PI);
    ctx.stroke();
  });

  //sweep line
  ctx.strokeStyle = "#F00";
  ctx.beginPath();
  ctx.moveTo(0, v.sweep);
  ctx.lineTo(c.width, v.sweep);
  ctx.stroke();

  //voronoi
  ctx.fillStyle = "#66F";
  v.vertices.forEach((Vector2 v) {
    ctx.beginPath();
    ctx.arc(v.x, v.y, 3, 0, 2*PI);
    ctx.fill();
  });

 /* ctx.strokeStyle = "#66F";
  ctx.lineWidth = 2;
  v.edges.forEach((HalfEdge e) {
    if(e.start != null && e.end != null) {
      ctx.beginPath();
      ctx.moveTo(e.start.x, e.start.y);
      ctx.lineTo(e.end.x, e.end.y);
      ctx.stroke();
    } else if(e.start != null) {
      ctx.beginPath();
      ctx.moveTo(e.start.x, e.start.y);
      ctx.lineTo(rng.nextInt(c.width),0);
      ctx.stroke();
    }
  }); */
}
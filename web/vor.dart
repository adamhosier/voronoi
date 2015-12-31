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

  int NUM_POINTS = 10;
  v = new Voronoi(getPoints(NUM_POINTS, 2271), c.getBoundingClientRect(), start:false);
  draw(v);

  window.onKeyDown.listen((KeyboardEvent e) {
    if(e.keyCode == 32) {
      if(v.q.isNotEmpty) {
        v.nextEvent();
        draw(v);
      }
    }
    if(e.keyCode == 83) {
      if(v.q.isEmpty || v.q.peek.y > v.sweep + 1) {
        v.q.push(new VoronoiNullEvent(v.sweep + 1));
      }
      v.nextEvent();
      draw(v);
    }
  });

}

List<Vector2> getPoints(int amt, [int seed]) {
  //return [new Vector2(200.0, 200.0), new Vector2(150.0, 250.0), new Vector2(225.0, 275.0), new Vector2(160.0, 350.0), new Vector2(300.0, 360.0)];
  List<Vector2> pts = new List();
  Random rng = new Random(seed);

  Rectangle b = new Rectangle(150, 150, 400, 400);
  for(int i = 0; i < amt; i++) {
    pts.add(new Vector2(b.left + rng.nextDouble() * b.width, b.top + rng.nextDouble() * b.height));
  }

  return pts;
}

draw(Voronoi v) {
  ctx.clearRect(0, 0, c.width, c.height);

  //circles
  ctx.strokeStyle = "#BDB";
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
  v.beachBreakpoints.forEach((Vector2 p) {
    ctx.beginPath();
    ctx.moveTo(p.x, p.y);
    ctx.lineTo(p.x, p.y - 3);
    ctx.stroke();
  });

  //sweep line
  ctx.strokeStyle = "#F00";
  ctx.beginPath();
  ctx.moveTo(0, v.sweep);
  ctx.lineTo(c.width, v.sweep);
  ctx.stroke();

  //voronoi points
  ctx.fillStyle = "#66F";
  v.vertices.forEach((Vector2 v) {
    ctx.beginPath();
    ctx.arc(v.x, v.y, 3, 0, 2*PI);
    ctx.fill();
  });

  /*//voronoi edges
  ctx.strokeStyle = "#66F";
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
  });*/
}
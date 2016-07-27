library map;

import "dart:html";
import "dart:math";
import "package:vor/geometry/geometry.dart";
import "package:vor/structs/dll.dart";
import "package:vor/voronoi/voronoi.dart";
import 'package:vor/sampler/sampler.dart';


CanvasElement c;
CanvasRenderingContext2D ctx;
Voronoi v;
DLL d;
Random rng = new Random();

int NUM_POINTS = 200;

main() {
  d = new DLL();
  c = document.getElementById("draw");
  ctx = c.getContext("2d");

  c.width = window.innerWidth;
  c.height = window.innerHeight;

  v = getVoronoi();
  draw(v);

  window.onKeyDown.listen((KeyboardEvent e) {
    if(e.keyCode == 32) {
      if(v.q.isNotEmpty) {
        v.nextEvent();
        draw(v);
      }
    }
    if(e.keyCode == 83) {
      v.q.push(new VoronoiNullEvent(v.sweep + 1));
      while(!(v.q.peek is VoronoiNullEvent)) {
        v.nextEvent();
      }
      v.nextEvent();
      draw(v);
    }
    if(e.keyCode == 13) {
      v.generate();
      draw(v);
    }
    if(e.keyCode == 82) { // r to reload
      v = getVoronoi();
      draw(v);
    }
  });

}

Voronoi getVoronoi() {
  return new Voronoi(getPoints(NUM_POINTS), c.getBoundingClientRect(), start:true);
}

List<Vector2> getPoints(int amt) {
  //return [new Vector2(101.0, 102.0), new Vector2(204.0,201.0), new Vector2(107.0, 203.0)];
  int padding = 100;
  Rectangle b = new Rectangle(padding, padding, c.width - 2*padding, c.height - 2*padding);

  //Sampler s = new UniformSampler(b);
  //Sampler s = new JitteredGridSampler(b);
  Sampler s = new PoissonDiskSampler(b);

  return s.generatePoints(amt);
}

draw(Voronoi v) {
  ctx.clearRect(0, 0, c.width, c.height);

  //sites
  ctx.fillStyle = "#000";
  ctx.strokeStyle = "#DDD";
  v.sites.forEach((Vector2 p) {
    ctx.beginPath();
    ctx.arc(p.x, p.y, 2, 0, 2*PI);
    ctx.fill();

    /*//arcs
    if(p.y <= v.sweep) {
      double xdist = sqrt(v.sweep * v.sweep - p.y * p.y);
      ctx.beginPath();
      ctx.moveTo(p.x - xdist, 0);
      ctx.quadraticCurveTo(p.x, p.y + v.sweep, p.x + xdist, 0);
      ctx.stroke();
    }*/
  });

  //sweep line
  ctx.strokeStyle = "#F00";
  ctx.beginPath();
  ctx.moveTo(0, v.sweep);
  ctx.lineTo(c.width, v.sweep);
  ctx.stroke();

  //circles
  /*ctx.fillStyle = "rgba(0,0,0,0.125)";
  ctx.lineWidth = 1;
  v.circles.forEach((Circle c) {
    ctx.beginPath();
    ctx.arc(c.x, c.y, c.r, 0, 2*PI);
    ctx.fill();
  });*/

  //voronoi edges
  ctx.strokeStyle = "#00F";
  v.edges.forEach((HalfEdge e) {
    if(e.o != null && e.twin.o != null) {
      Vector2 start = e.o.p;
      Vector2 end = e.twin.o.p;
      ctx.beginPath();
      ctx.moveTo(start.x, start.y);
      ctx.lineTo(end.x, end.y);
      ctx.stroke();
    }
  });

  /*//voronoi points
  ctx.fillStyle = "#FFF";
  ctx.strokeStyle = "#00F";
  v.vertices.forEach((Vector2 v) {
    ctx.beginPath();
    ctx.arc(v.x, v.y, 3, 0, 2*PI);
    ctx.fill();
    ctx.stroke();
  });*/
}
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

int NUM_POINTS = 500;

Rectangle box;


main() {
  d = new DLL();
  c = document.getElementById("draw");
  ctx = c.getContext("2d");

  c.width = window.innerWidth;
  c.height = window.innerHeight;
  int padding = 50;
  box = new Rectangle(padding, padding, c.width - 2*padding, c.height - 2*padding);

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
    if(e.keyCode == 65) { // a to reload
      v = getVoronoi();
      draw(v);
    }
  });
}

Voronoi getVoronoi() {
  return new Voronoi(getPoints(NUM_POINTS), box, start:false);
}

List<Vector2> getPoints(int amt) {
  Sampler s = new PoissonDiskSampler(box);

  return s.generatePoints(amt);
}

draw(Voronoi v) {
  ctx.clearRect(0, 0, c.width, c.height);

  //sites
  ctx.fillStyle = "#000";
  ctx.strokeStyle = "#DDD";
  v.sites.forEach((Vector2 p) {
    ctx.beginPath();
    ctx.arc(p.x, p.y, 2, 0, 2 * PI);
    ctx.fill();
  });

  //voronoi edges
  ctx.strokeStyle = "#00F";
  v.edges.forEach((HalfEdge e) {
    if(e.start != null && e.end != null) {
      Vector2 start = e.start;
      Vector2 end = e.end;

      double angle = 5 * PI / 6;
      angle = atan2((end.y - start.y), (end.x - start.x)) - angle;

      ctx.beginPath();
      ctx.moveTo(start.x, start.y);
      ctx.lineTo(end.x, end.y);
      ctx.stroke();
      e = e.next;
    }
  });
}
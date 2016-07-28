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

int NUM_POINTS = 20;

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

  stepStart = rng.nextInt(v.edges.length);
  curr = v.edges[stepStart];

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
    if(e.keyCode == 70) { // f to step
      drawNextStep(v);
    }
  });
}

Voronoi getVoronoi() {
  return new Voronoi(getPoints(NUM_POINTS), box, start:true);
}

List<Vector2> getPoints(int amt) {

  //Sampler s = new UniformSampler(box);
  //Sampler s = new JitteredGridSampler(box);
  //Sampler s = new PoissonDiskSampler(new Rectangle(box.left + 50, box.top + 50, box.width - 100, box.height - 100));
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

    //arcs
    if (p.y <= v.sweep) {
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
    if(e.start != null && e.end != null) {
      Vector2 start = e.start;
      Vector2 end = e.end;

      double length = 6.0;
      double angle = 5 * PI / 6;
      angle = atan2((end.y - start.y), (end.x - start.x)) - angle;
      Vector2 markStart = new Vector2((start.x + 3 * end.x) / 4, (start.y + 3 * end.y) / 4);
      Vector2 markEnd = new Vector2(markStart.x + cos(angle) * length, markStart.y + sin(angle) * length);

      ctx.beginPath();
      ctx.moveTo(start.x, start.y);
      ctx.lineTo(end.x, end.y);
      ctx.moveTo(markStart.x, markStart.y);
      ctx.lineTo(markEnd.x, markEnd.y);
      ctx.stroke();
      e = e.next;
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

int stepStart;
HalfEdge curr;
drawNextStep(Voronoi v) {
  if(curr.next == null) return;
  draw(v);
  HalfEdge e = v.edges[stepStart];
  ctx.beginPath(); ctx.arc(e.start.x, e.start.y, 2, 0, 2*PI); ctx.fill();
  ctx.strokeStyle = "#00F";

  while(e.next != null && e != curr) {
    Vector2 start = e.start;
    Vector2 end = e.end;

    double length = 6.0;
    double angle = 5 * PI / 6;
    angle = atan2((end.y - start.y), (end.x - start.x)) - angle;
    Vector2 markStart = new Vector2((start.x + 3 * end.x) / 4, (start.y + 3 * end.y) / 4);
    Vector2 markEnd = new Vector2(markStart.x + cos(angle) * length, markStart.y + sin(angle) * length);

    ctx.beginPath();
    ctx.moveTo(start.x, start.y);
    ctx.lineTo(end.x, end.y);
    ctx.moveTo(markStart.x, markStart.y);
    ctx.lineTo(markEnd.x, markEnd.y);
    ctx.stroke();

    e = e.next;
  }

  curr = curr.next;
}
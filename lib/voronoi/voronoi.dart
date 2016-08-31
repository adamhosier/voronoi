library voronoi;

import "dart:math";
import "package:vor/structs/priorityQueue.dart";
import "package:vor/geometry/geometry.dart";
import 'package:vor/structs/leafedTree.dart';

part "doublyConnectedEdgeList.dart";
part "beachLine.dart";

class Voronoi {

  static double Epsilon = 0.0001;

  PriorityQueue<VoronoiEvent> _queue;
  BeachLine _beach;
  DoublyConnectedEdgeList _d;
  List<VoronoiSite> _sites;
  List<Circle> circles;

  double sweep = 0.0;

  List<Vector2> get sites => _sites.map((VoronoiSite s) => s.pos);
  List<Vector2> get vertices => _d.vertices.map((Vertex v) => v.p).toList();
  List<HalfEdge> get edges => _d.edges;
  List<Vector2> get beachBreakpoints => _beach.getBreakpoints(sweep);
  List<Face> get faces => _d.faces;
  DoublyConnectedEdgeList get dcel => _d;

  Rectangle<double> boundingBox;

  PriorityQueue<VoronoiEvent> get q => _queue;
  BeachLine get t => _beach;

  Voronoi(List<Vector2> pts, this.boundingBox, {start : true}) {
    if(pts.length == 0) throw new ArgumentError("Voronoi diagram must contain at least 1 site");

    // init structures
    _queue = new PriorityQueue();
    _beach = new BeachLine();
    _d = new DoublyConnectedEdgeList();
    _sites = pts.map((Vector2 pt) => new VoronoiSite(pt)).toList();
    circles = new List();

    // add each point to event queue based on y coord
    _sites.forEach((VoronoiSite s) => _queue.push(new VoronoiSiteEvent(s)));

    // start processing events
    if(start) generate();
  }

  void generate() {
    while(_queue.isNotEmpty) {
      nextEvent();
    }
    if(sweep < boundingBox.bottom) _handleEvent(new VoronoiNullEvent(boundingBox.bottom));
    bindToBox();
  }

  void nextEvent() {
    if(_queue.isNotEmpty) {
      _handleEvent(_queue.pop);
    }
  }

  void bindToBox() {
    _beach.tree.internalNodes.forEach((BeachInternalNode node) {
      HalfEdge e = node.edge;
      // add vertices for infinite edges
      Vector2 p = _beach.calculateBreakpoint(node.a, node.b, sweep);
      double ratio = 1.0;
      while(boundingBox.containsPoint((p * ratio).asPoint)) {
        // extend to outside the box arbitrarily, we will clip it back later
        ratio *= 2;
      }
      e.twin.o = _d.newVertex(p * ratio);
    });

    // trim edges
    Clipper c = new Clipper(boundingBox);
    _d.edges.removeWhere((HalfEdge e) => c.isOutside(e.start, e.end));
    _d.vertices.removeWhere((Vertex v) => !boundingBox.containsPoint(v.p.asPoint));
    _d.edges.forEach(c.clip);

    // close edges
    HalfEdge start = _d.edges.firstWhere((HalfEdge e) => e.prev == null);
    HalfEdge end = start;
    HalfEdge prev = null;
    do {
      HalfEdge curr = start;
      // find loose edge
      while (curr.next != null) curr = curr.next;

      HalfEdge e1 = _d.newEdge();
      HalfEdge e2 = _d.newEdge();
      e1.twin = e2;
      e1.o = curr.twin.o;
      // deal with corner cases
      if (curr.end.x != start.start.x && curr.end.y != start.start.y) {
        HalfEdge e3 = _d.newEdge();
        HalfEdge e4 = _d.newEdge();
        e3.twin = e4;
        e1.next = e3;
        e3.next = start;
        e4.o = start.o;
        curr.next = e1;
        Vertex cornerVertex = (curr.end.x > start.start.x) ?
          (curr.end.y > start.start.y) ? _d.newVertex(new Vector2(curr.end.x, start.start.y)) : _d.newVertex(new Vector2(start.start.x, curr.end.y)) :
          (curr.end.y < start.start.y) ? _d.newVertex(new Vector2(curr.end.x, start.start.y)) : _d.newVertex(new Vector2(start.start.x, curr.end.y));
        e2.o = cornerVertex;
        e3.o = cornerVertex;
      } else {
        e2.o = start.o;

        // set pointers between them
        curr.next = e1;
        e1.next = start;
        e2.prev = prev;
        prev = e2;
      }

      start = curr.twin;
    } while (start != end);
  }

  void _handleEvent(VoronoiEvent e) {
    sweep = e.y;
    if(e is VoronoiSiteEvent) _handleSiteEvent(e.s);
    else if(e is VoronoiCircleEvent) _handleCircleEvent(e);
  }

  void _handleSiteEvent(VoronoiSite s) {
    if(_beach.isEmpty) {
      _beach.tree.root = new BeachLeaf(s);
    } else {
      BeachLeaf closest = _beach.findLeaf(s.x, sweep);

      // if circle has an event, mark it as a false alarm
      _checkFalseAlarm(closest);

      // grow the tree
      BeachInternalNode newTree = new BeachInternalNode();
      BeachInternalNode newSubTree = new BeachInternalNode();
      BeachLeaf leafL = closest.clone();
      BeachLeaf leafM = new BeachLeaf(s);
      BeachLeaf leafR = closest.clone();

      newTree.l = leafL;
      newTree.r = newSubTree;
      newTree.a = closest.site;
      newTree.b = s;
      newSubTree.l = leafM;
      newSubTree.r = leafR;
      newSubTree.a = s;
      newSubTree.b = closest.site;

      if(closest.parent == null) {
        _beach.tree.root = newTree;
      } else if(closest.parent.l == closest) {
        closest.parent.l = newTree;
      } else {
        closest.parent.r = newTree;
      }

      // update voronoi structure
      HalfEdge e1 = _d.newEdge();
      HalfEdge e2 = _d.newEdge();
      e1.twin = e2;
      newTree.edge = e2;
      newSubTree.edge = e1;

      // check new trips
      _checkTriple(leafL.leftLeaf, leafL, leafM);
      _checkTriple(leafM, leafR, leafR.rightLeaf);
    }
  }

  void _handleCircleEvent(VoronoiCircleEvent e) {
    //check for false alarm
    if(e.isFalseAlarm) {
      return;
    }

    BeachLeaf leaf = e.arc;
    BeachInternalNode oldNode = leaf.parent;
    BeachInternalNode brokenNode = _beach.findInternalNode(e.c.o.x, sweep);
    bool oldLeftOfBroken = oldNode.isInLeftSubtreeOf(brokenNode);

    // events
    BeachLeaf leafL = leaf.leftLeaf;
    BeachLeaf leafR = leaf.rightLeaf;
    _checkFalseAlarm(leafL);
    _checkFalseAlarm(leafR);

    // remove intersection node
    if(oldNode.parent.l == oldNode) {
      oldNode.parent.l = leaf.brother;
    } else {
      oldNode.parent.r = leaf.brother;
    }

    // update node referencing old arc (fix broken node)
    brokenNode.a = (brokenNode.l.rightMostLeaf as BeachLeaf).site;
    brokenNode.b = (brokenNode.r.leftMostLeaf as BeachLeaf).site;

    // diagram
    Vertex v = _d.newVertex(e.c.o);
    HalfEdge e1 = _d.newEdge();
    HalfEdge e2 = _d.newEdge();
    e1.twin = e2;

    // connect structure
    if(oldLeftOfBroken) {
      brokenNode.edge.next = e1;
      e2.next = oldNode.edge.twin;
      oldNode.edge.next = brokenNode.edge.twin;
    } else {
      oldNode.edge.next = e1;
      e2.next = brokenNode.edge.twin;
      brokenNode.edge.next = oldNode.edge.twin;
    }

    // attach new edge to vertex
    e1.o = v;

    // attach old node edges to this vertex
    oldNode.edge.twin.o = v;
    brokenNode.edge.twin.o = v;

    // update edge of new fixed node
    brokenNode.edge = e1;

    _checkTriple(leafL.leftLeaf, leafL, leafL.rightLeaf);
    _checkTriple(leafR.leftLeaf, leafR, leafR.rightLeaf);
  }

  void _checkFalseAlarm(BeachLeaf leaf) {
    if(leaf.event != null) {
      leaf.event.isFalseAlarm = true;
      circles.remove(leaf.event.c);
    }
  }

  void _checkTriple(BeachLeaf a, BeachLeaf b, BeachLeaf c) {
    if(a == null || b == null || c == null) return;

    double syden = 2 * ((a.y - b.y)*(b.x - c.x) - (b.y - c.y)*(a.x - b.x));
    if(syden < 0) { //if the circle converges
      // calculate intersection
      double synum = (c.x*c.x + c.y*c.y - b.x*b.x - b.y*b.y)*(a.x - b.x) - (b.x*b.x + b.y*b.y - a.x*a.x - a.y*a.y)*(b.x - c.x);
      double sy = synum / syden;
      double sx = ((c.x*c.x + c.y*c.y - b.x*b.x - b.y*b.y)*(a.y - b.y) - (b.x*b.x + b.y*b.y - a.x*a.x - a.y*a.y)*(b.y - c.y)) / -syden;
      Vector2 o = new Vector2(sx, sy);

      // set the new event
      Circle cir = new Circle(o, (a.pos - o).magnitude);
      circles.add(cir);
      VoronoiCircleEvent e = new VoronoiCircleEvent(cir);
      _queue.push(e);
      b.event = e;
      e.arc = b;
    }
  }
}

abstract class VoronoiEvent implements Comparable {
  double get y;

  int compareTo(VoronoiEvent other) {
    return -y.compareTo(other.y);
  }
}

class VoronoiSiteEvent extends VoronoiEvent {
  VoronoiSite s;

  double get y => s.y;

  VoronoiSiteEvent(this.s);

}

class VoronoiCircleEvent extends VoronoiEvent {
  Circle c;
  BeachLeaf arc;
  bool isFalseAlarm = false;

  double get y => c.bottom;

  VoronoiCircleEvent(this.c);
}

class VoronoiNullEvent extends VoronoiEvent {
  double y;

  VoronoiNullEvent(this.y);
}

class VoronoiSite {
  Vector2 pos;

  get x => pos.x;
  get y => pos.y;

  VoronoiSite(this.pos);

  bool operator ==(Object other) => other is VoronoiSite && other.x == this.x && other.y == this.y;

  String toString() {
    return "Voronoi site at ($x, $y)";
  }
}
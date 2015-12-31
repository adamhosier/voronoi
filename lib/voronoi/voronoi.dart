library voronoi;

import "dart:math";
import "package:vor/structs/pq.dart";
import "package:vor/geometry/geometry.dart";

part "dcel.dart";
part "tree.dart";

class Voronoi {

  static double Epsilon = 0.0000001;

  PQ<VoronoiEvent> _q;
  BST _t;
  DCEL _d;
  List<VoronoiSite> _sites;
  List<Circle> circles;

  double sweep = 0.0; //for drawing purposes

  List<Vector2> get sites => _sites.map((VoronoiSite s) => s.pos);
  List<Vector2> get vertices => _d.vertices.map((_Vert v) => v.p).toList();
  List<HalfEdge> get edges => _d.edges;
  List<Vector2> get beachBreakpoints => _t.getBreakpoints(sweep);

  PQ<VoronoiEvent> get q => _q;
  BST get t => _t;

  Voronoi(List<Vector2> pts, Rectangle box, {start : true}) {

    // init structures
    _q = new PQ();
    _t = new BST();
    _d = new DCEL();
    _sites = pts.map((Vector2 pt) => new VoronoiSite(pt)).toList();
    circles = new List();

    // add each point to event queue based on y coord
    _sites.forEach((VoronoiSite s) => _q.push(new VoronoiSiteEvent(s)));

    // start processing events
    while(_q.isNotEmpty && start) {
      nextEvent();
    }
  }

  void nextEvent() {
    if(_q.isNotEmpty) {
      _handleEvent(_q.pop());
    }
  }

  void _handleEvent(VoronoiEvent e) {
    sweep = e.y;
    if(e is VoronoiSiteEvent) _handleSiteEvent(e.s);
    else if(e is VoronoiCircleEvent) _handleCircleEvent(e);
  }

  void _handleSiteEvent(VoronoiSite s) {
    if(_t.isEmpty) {
      _t.root = new BSTLeaf(s);
    } else {
      BSTLeaf closest = _t.search(s);

      // if circle has an event, mark it as a false alarm
      _checkFalseAlarm(closest);

      // grow the tree
      BSTInternalNode newTree = new BSTInternalNode();
      BSTInternalNode newSubTree = new BSTInternalNode();
      BSTLeaf leafL = closest.clone();
      BSTLeaf leafM = new BSTLeaf(s);
      BSTLeaf leafR = closest.clone();

      newTree.l = leafL;
      newTree.r = newSubTree;
      newTree.a = closest.site;
      newTree.b = s;
      newSubTree.l = leafM;
      newSubTree.r = leafR;
      newSubTree.a = s;
      newSubTree.b = closest.site;

      if(closest.parent == null) {
        _t.root = newTree;
      } else if(closest.parent.l == closest) {
        closest.parent.l = newTree;
      } else {
        closest.parent.r = newTree;
      }

      // update voronoi structure
      HalfEdge e1 = new HalfEdge();
      HalfEdge e2 = new HalfEdge();
      e1.twin = e2;
      newTree.edge = e1;
      newSubTree.edge = e2;

      _d.edges.add(e1);
      _d.edges.add(e2);

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

    BSTLeaf leaf = e.arc;
    BSTInternalNode oldIntersection = leaf.parent;

    // events
    BSTLeaf leafL = leaf.leftLeaf;
    BSTLeaf leafR = leaf.rightLeaf;
    _checkFalseAlarm(leafL);
    _checkFalseAlarm(leafR);

    // remove intersection node
    BSTInternalNode n = new BSTInternalNode();
    if(oldIntersection.parent.l == oldIntersection) {
      oldIntersection.parent.l = leaf.brother;
    } else {
      oldIntersection.parent.r = leaf.brother;
    }
    _t.fix(e.c.o, e.y);

    // diagram
    _Vert v = new _Vert(e.c.o);
    HalfEdge e1 = new HalfEdge();
    HalfEdge e2 = new HalfEdge();
    e1.twin = e2;

    e1.o = v;
    oldIntersection.edge.twin.o = v;
    oldIntersection.edge.next = e1;
    oldIntersection.parent.edge.o = v;
    oldIntersection.parent.edge.twin.next = e1;

    e2.next = oldIntersection.edge.twin;

    _d.vertices.add(v);
    _d.edges.add(e1);
    _d.edges.add(e2);

    _checkTriple(leafL.leftLeaf, leafL, leafL.rightLeaf);
    _checkTriple(leafR.leftLeaf, leafR, leafR.rightLeaf);
  }

  void _checkFalseAlarm(BSTLeaf leaf) {
    if(leaf.event != null) {
      leaf.event.isFalseAlarm = true;
      circles.remove(leaf.event.c);
    }
  }

  void _checkTriple(BSTLeaf a, BSTLeaf b, BSTLeaf c) {
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
      _q.push(e);
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
  BSTLeaf arc;
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

  bool operator ==(Object other) => other is VoronoiSite && other.x == this.x &&
                                                            other.y == this.y;

  String toString() {
    return "Voronoi site at ($x, $y)";
  }
}
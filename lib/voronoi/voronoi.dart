library voronoi;

import "dart:math";
import "package:vor/structs/pq.dart";
import "package:vor/geometry/geometry.dart";

part "dcel.dart";
part "tree.dart";

class Voronoi {

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

  PQ<VoronoiEvent> get q => _q; //DEBUG
  BST get t => _t; //DEBUG

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
    else _handleCircleEvent(e);
  }

  void _handleSiteEvent(VoronoiSite s) {
    if(_t.isEmpty) {
      _t.root = new BSTLeaf(s);
    } else {
      BSTLeaf closest = _t.search(s);

      // if circle has an event, mark it as a false alarm
      closest.event?.isFalseAlarm = true;

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
      newSubTree.a = s;
      newSubTree.b = closest.site;
      newSubTree.l = leafM;
      newSubTree.r = leafR;

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

  void _checkTriple(BSTLeaf a, BSTLeaf b, BSTLeaf c) {
    if(a == null || b == null || c == null) return;

    double syden = 2 * ((a.y - b.y) * (b.x - c.x) - (b.y - c.y) * (a.x - b.x));
    if(syden > 0) { //if the circle converges
      // calculate intersection
      double synum = (pow(c.x, 2) + pow(c.y, 2) - pow(b.x, 2) - pow(b.y, 2)) * (a.x - b.x) -
                     (pow(b.x, 2) + pow(b.y, 2) - pow(a.x, 2) - pow(a.y, 2)) * (b.x - c.x);
      double sy = synum / syden;
      double sx = ((pow(c.x, 2) + pow(c.y, 2) - pow(b.x, 2) - pow(b.y, 2)) * (a.y - b.y) -
                   (pow(b.x, 2) + pow(b.y, 2) - pow(a.x, 2) - pow(a.y, 2)) * (b.y - c.y)) / -syden;
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

  void _handleCircleEvent(VoronoiCircleEvent e) {
    //check for false alarm
    if(e.isFalseAlarm) return;

    BSTLeaf leaf = e.arc;

    leaf.leftLeaf.event?.isFalseAlarm = true;
    leaf.rightLeaf.event?.isFalseAlarm = true;

    _Vert v = new _Vert(e.c.o);
    HalfEdge e1 = new HalfEdge();
    HalfEdge e2 = new HalfEdge();
    e1.twin = e2;

    e1.o = v;
    leaf.parent.edge.twin.o = v;
    leaf.parent.edge.next = e1;
    leaf.parent.parent.edge.o = v;
    leaf.parent.parent.edge.twin.next = e1;

    e2.next = leaf.parent.edge.twin;

    _d.vertices.add(v);
    _d.edges.add(e1);
    _d.edges.add(e2);

    BSTInternalNode n = new BSTInternalNode();
    n.a = leaf.leftLeaf.site;
    n.b = leaf.rightLeaf.site;
    n.l = leaf.uncle;
    n.r = leaf.brother;
    n.edge = e1;

    if(leaf.parent.parent.parent.l == leaf.parent.parent) {
      leaf.parent.parent.parent.l = n;
    } else {
      leaf.parent.parent.parent.r = n;
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
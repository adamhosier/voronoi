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

  List<Vector2> get sites => _sites.map((VoronoiSite s) => s.pos);
  double get sweep => _q.isEmpty ? -1 : _q.peek.y;
  PQ<VoronoiEvent> get q => _q;

  Voronoi(List<Vector2> pts, Rectangle box, {start : true}) {

    // init structures
    _q = new PQ();
    _t = new BST();
    _d = new DCEL();
    _sites = pts.map((Vector2 pt) => new VoronoiSite(pt)).toList();

    // add each point to event queue based on y coord
    _sites.forEach((VoronoiSite s) => _q.push(new VoronoiSiteEvent(s)));

    // start processing events
    while(_q.isNotEmpty && start) {
      nextEvent();
    }
  }

  void nextEvent() {
    if(_q.isNotEmpty) {
      VoronoiEvent e = _q.pop();
      if(e is VoronoiCircleEvent && e.isFalseAlarm) nextEvent();
      else _handleEvent(e);
    }
  }

  void _handleEvent(VoronoiEvent e) {
    if(e is VoronoiSiteEvent) _handleSiteEvent(e.s);
    else _handleCircleEvent(e.y);
  }

  void _handleSiteEvent(VoronoiSite s) {
    if(_t.isEmpty) {
      _t.root = new BSTLeaf(s);
    } else {
      BSTLeaf closest = _t.search(s);
      if(closest.event != null) closest.event.isFalseAlarm = true;

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
      _Edge e1 = new _Edge();
      _Edge e2 = new _Edge();
      e1.twin = e2;
      newTree.edge = e1;
      newSubTree.edge = e2;

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
      VoronoiCircleEvent e = new VoronoiCircleEvent(new Circle(o, (a.pos - o).magnitude));
      _q.push(e);
      a.event = e;
    }
  }

  void _handleCircleEvent(double y) {

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
  bool isFalseAlarm = false;

  double get y => c.bottom;

  VoronoiCircleEvent(this.c);
}

class VoronoiSite {
  Vector2 pos;

  get x => pos.x;
  get y => pos.y;

  VoronoiSite(this.pos);

  String toString() {
    return "Voronoi site at ($x, $y)";
  }
}
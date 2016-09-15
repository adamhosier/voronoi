// Implementation of the trapezoidal map structure and algorithm
//   to work in conjunction with doublyConnectedEdgeList.dart
// Described at http://cgm.cs.mcgill.ca/~athens/cs507/Projects/2002/JukkaKaartinen/
// Adam Hosier 2016

part of voronoi;


class TrapezoidalMap {
  _TMapGraph _t;
  _TMapSearch _s;

  Rectangle _box;
  Random rng = new Random();

  TrapezoidalMap(this._box) {
    _t = new _TMapGraph();
    _s = new _TMapSearch(_t.getBoundingTrapezoid(_box));
  }

  // finds the face associated with the trapezoid that contains p
  Face search(Vector2 p) {
    return _s.find(p).trapezoid.face;
  }

  void add(HalfEdge e) {
    // we only want edges that go left to right
    e = (e.start.x < e.end.x) ? e : e.twin;

    // find trapezoids intersected
    _TMapLeaf startLeaf = _s.find(e.start);
    _Trapezoid start = startLeaf.trapezoid;
    List<_Trapezoid> path = [start];
    for(int i = 0; path[i]?.right != null && e.end.x > path[i].right.x; i++) {
      if (e.pointLiesAbove(path[i].right.p)) {
        path.add(path[i].lr);
      } else {
        path.add(path[i].ur);
      }
    }

    // two cases, first is that the edge is contained in a single trapezoid
    if (path.length == 1) {
      // update the graph
      _Trapezoid a = new _Trapezoid();
      _Trapezoid b = new _Trapezoid();
      _Trapezoid c = new _Trapezoid();
      _Trapezoid d = new _Trapezoid();

      a.ur = c; c.ll = a; c.ul = a;
      a.lr = d; d.ul = a; d.ll = a;
      b.ul = c; c.lr = b; c.ur = b;
      b.ll = d; d.ur = b; d.ur = b;

      start.ul?.lr = a; start.ll?.ur = a;
      start.ur?.ll = b; start.lr?.ul = b;

      a.left = start.left;
      a.right = e.o;
      a.top = start.top;
      a.bottom = start.bottom;
      b.left = e.twin.o;
      b.right = start.right;
      b.top = start.top;
      b.bottom = start.bottom;
      c.left = e.o;
      c.right = e.twin.o;
      c.top = start.top;
      c.bottom = e;
      d.left = e.o;
      d.right = e.twin.o;
      d.top = e;
      d.bottom = start.bottom;

      // update the search structure
      _TMapXNode newRoot = new _TMapXNode();
      _TMapXNode new2 = new _TMapXNode();
      _TMapYNode new21 = new _TMapYNode();
      newRoot.v = e.o;
      new2.v = e.twin.o;
      new21.e = e;
      var la = new _TMapLeaf(a); la.parents.add(newRoot);
      var lb = new _TMapLeaf(b); lb.parents.add(new2);
      var lc = new _TMapLeaf(c); lc.parents.add(new21);
      var ld = new _TMapLeaf(d); ld.parents.add(new21);
      newRoot._1 = la;
      newRoot._2 = new2;
      new2._1 = new21;
      new2._2 = lb;
      new21._1 = lc;
      new21._2 = ld;

      if(startLeaf.parents.isEmpty) {
        _s.root = newRoot;
      } else {
        startLeaf.parents.forEach((_TMapInternalNode parent) {
          if(parent._1 == startLeaf) parent._1 = newRoot;
          else parent._2 = newRoot;
        });
      }
    } else { //edge spans multiple trapezoids TODO
    }
  }

  void addAll(List<HalfEdge> edges) {
    // copy edge list for modification
    List<HalfEdge> es = new List.from(edges);
    es.shuffle(rng);
    es.forEach(add);
  }

}

class _TMapGraph {
  _Trapezoid getBoundingTrapezoid(Rectangle rect) {
    _Trapezoid t = new _Trapezoid();
    t.top = new HalfEdge();
    t.top.twin = new HalfEdge();
    t.top.o = new Vertex(new Vector2.fromPoint(rect.topLeft));
    t.top.twin.o = new Vertex(new Vector2.fromPoint(rect.topRight));

    t.bottom = new HalfEdge();
    t.bottom.twin = new HalfEdge();
    t.bottom.o = new Vertex(new Vector2.fromPoint(rect.bottomLeft));
    t.bottom.twin.o = new Vertex(new Vector2.fromPoint(rect.bottomRight));

    t.left = t.top.o;
    t.right = t.top.twin.o;

    return t;
  }
}

class _Trapezoid {
  HalfEdge top;
  HalfEdge bottom;
  Vertex left;
  Vertex right;

  _Trapezoid ur;
  _Trapezoid lr;
  _Trapezoid ul;
  _Trapezoid ll;

  Face get face => top.face;
}

class _TMapSearch {
  _TMapNode root;

  int get depth => root.depth;

  _TMapSearch(_Trapezoid t) {
    root = new _TMapLeaf(t);
  }

  _TMapLeaf find(Vector2 p) {
    return _find(root, p);
  }

  _TMapLeaf _find(_TMapNode node, Vector2 p) {
    if(node is _TMapInternalNode) {
      if(node.compareTo(p) < 0) {
        return _find(node._1, p);
      } else {
        return _find(node._2, p);
      }
    } else if(node is _TMapLeaf) {
      return node;
    }
    throw new FallThroughError();
  }
}

abstract class _TMapNode {
  int get depth;
}

class _TMapLeaf extends _TMapNode {
  _Trapezoid trapezoid;
  List<_TMapInternalNode> parents = [];

  int get depth => 1;

  _TMapLeaf(this.trapezoid);
}

abstract class _TMapInternalNode extends _TMapNode {
  _TMapNode _1, _2;

  int get depth => 1 + max(_1.depth, _2.depth);

  int compareTo(Vector2 p);
}

class _TMapXNode extends _TMapInternalNode {
  Vertex v;

  int compareTo(Vector2 p) {
    return p.x.compareTo(v.x);
  }
}

class _TMapYNode extends _TMapInternalNode {
  HalfEdge e;

  int compareTo(Vector2 p) {
    return e.pointLiesAbove(p) ? -1 : 1;
  }
}
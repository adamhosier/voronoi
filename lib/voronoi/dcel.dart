part of voronoi;

class DCEL {
  List<Vertex> vertices = new List();
  List<HalfEdge> edges = new List();

  HalfEdge newEdge() {
    HalfEdge edge = new HalfEdge();
    edges.add(edge);
    return edge;
  }

  Vertex newVert(Vector2 o) {
    Vertex vert = new Vertex(o);
    vertices.add(vert);
    return vert;
  }

  void removeEdge(HalfEdge e) {
    edges.remove(e);
  }

  void removeVert(Vertex v) {
    vertices.remove(v);
  }
}

class HalfEdge {
  Vertex o; //origin
  HalfEdge _twin;
  _Face face;
  HalfEdge _next;
  HalfEdge _prev;

  Vector2 get start => o?.p;
  Vector2 get end => twin?.o?.p;
  HalfEdge get twin => _twin;

  HalfEdge get next => _next;
  void set next(HalfEdge other) {
    this._next = other;
    other._prev = this;
  }

  HalfEdge get prev => _prev;
  void set prev(HalfEdge other) {
    this._prev = other;
    other._next = this;
  }

  void set twin(HalfEdge t) {
    this._twin = t;
    t._twin = this;
  }

  String toString() {
    return "Edge start: $start, end $end";
  }
}

class _Face {
  HalfEdge edge;

  _Face(this.edge);
}

class Vertex {
  Vector2 p;
  HalfEdge e;

  Vertex(this.p);
}
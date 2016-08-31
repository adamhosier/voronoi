part of voronoi;

class DoublyConnectedEdgeList {
  List<Vertex> vertices = new List();
  List<HalfEdge> edges = new List();

  List<Face> get faces => []; //TODO

  HalfEdge newEdge() {
    HalfEdge edge = new HalfEdge();
    edges.add(edge);
    return edge;
  }

  Vertex newVertex(Vector2 o) {
    Vertex vert = new Vertex(o);
    vertices.add(vert);
    return vert;
  }

  void removeEdge(HalfEdge e) {
    edges.remove(e);
  }

  void removeVertex(Vertex v) {
    vertices.remove(v);
  }
}

class HalfEdge {
  Vertex o; //origin
  HalfEdge _twin;
  Face face;
  HalfEdge _next;
  HalfEdge _prev;

  Vector2 get start => o?.p;
  Vector2 get end => twin?.o?.p;
  HalfEdge get twin => _twin;

  HalfEdge get next => _next;
  void set next(HalfEdge other) {
    this._next = other;
    other?._prev = this;
  }

  HalfEdge get prev => _prev;
  void set prev(HalfEdge other) {
    this._prev = other;
    other?._next = this;
  }

  void set twin(HalfEdge t) {
    this._twin = t;
    t._twin = this;
  }
}

class Face {
  HalfEdge edge;

  Face(this.edge);
}

class Vertex {
  Vector2 p;
  HalfEdge e;

  Vertex(this.p);
}
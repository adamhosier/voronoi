part of voronoi;

class DCEL {
  List<_Vert> vertices = new List();
  List<HalfEdge> edges = new List();

}

class HalfEdge {
  _Vert o; //origin
  HalfEdge _twin;
  _Face face;
  HalfEdge _next;
  HalfEdge _prev;

  Vector2 get start => o?.p;
  Vector2 get end => next?.o?.p;
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
}

class _Face {
  HalfEdge edge;

  _Face(this.edge);
}

class _Vert {
  Vector2 p;
  HalfEdge e;

  _Vert(this.p);
}
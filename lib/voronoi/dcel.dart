part of voronoi;

class DCEL {
  List<_Edge> edges = new List();
  List<_Face> faces = new List();
  List<_Vert> vertices = new List();

}

class _Edge {
  _Vert o; //origin
  _Edge _twin;
  _Face face;
  _Edge next;
  _Edge prev;

  _Edge get twin => _twin;

  void set twin(_Edge t) {
    this._twin = t;
    t._twin = this;
  }
}

class _Face {
  _Edge edge;

  _Face(this.edge);
}

class _Vert {
  Vector2 p;
  _Edge e;

  _Vert(this.p);
}
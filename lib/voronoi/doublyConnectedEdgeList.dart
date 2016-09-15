part of voronoi;

class DoublyConnectedEdgeList {
  static NullFace NULL_FACE = new NullFace();

  List<Vertex> vertices = new List();
  List<HalfEdge> edges = new List();
  Map<Vector2, Face> _faces = new Map();

  List<Face> get faces => _faces.values.toList();

  static DoublyConnectedEdgeList fromRectangle(Rectangle r, Vector2 center) {
    DoublyConnectedEdgeList d = new DoublyConnectedEdgeList();
    HalfEdge top = d.newFullEdge();
    HalfEdge left = d.newFullEdge();
    HalfEdge bottom = d.newFullEdge();
    HalfEdge right = d.newFullEdge();
    top.next = right;
    right.next = bottom;
    bottom.next = left;
    left.next = top;

    top.twin.next = left.twin;
    left.twin.next = bottom.twin;
    bottom.twin.next = right.twin;
    right.twin.next = top.twin;

    d.newFaceWithEdge(center, top);
    Vertex tl = d.newVertex(new Vector2.fromPoint(r.topLeft));
    Vertex tr = d.newVertex(new Vector2.fromPoint(r.topRight));
    Vertex bl = d.newVertex(new Vector2.fromPoint(r.bottomLeft));
    Vertex br = d.newVertex(new Vector2.fromPoint(r.bottomRight));

    top.o = tl; top.twin.o = tr;
    left.o = bl; left.twin.o = tl;
    bottom.o = br; bottom.twin.o = bl;
    right.o = tr; right.twin.o = br;
    return d;
  }

  // cleans up the dcel, removing edges marked as invalid
  void _clean() {
    edges.removeWhere((HalfEdge e) => !e.valid);
    vertices.removeWhere((Vertex v) => !v.valid);
  }

  Face newFace(Vector2 center) {
    Face face = new Face(center);
    _faces[center] = face;
    return face;
  }

  Face newFaceWithEdge(Vector2 center, HalfEdge edge) {
    Face face = newFace(center);
    face.edge = edge;
    return face;
  }

  HalfEdge newEdge() {
    HalfEdge edge = new HalfEdge();
    edges.add(edge);
    return edge;
  }

  // creates a new edge that's a twin of [twin]
  HalfEdge newTwinEdge(HalfEdge twin) {
    HalfEdge edge = newEdge();
    edge.twin = twin;
    return edge;
  }

  // creates a half edge with its twin attached
  HalfEdge newFullEdge() {
    HalfEdge edge = newEdge();
    edge.twin = newEdge();
    return edge;
  }


  HalfEdge newEdgeForFace(Face face) {
    HalfEdge edge = newEdge();
    face.edge = edge;
    return edge;
  }

  HalfEdge newTwinEdgeForFace(HalfEdge twin, Face face) {
    HalfEdge edge = newTwinEdge(twin);
    face.edge = edge;
    return edge;
  }

  Vertex newVertex(Vector2 o) {
    Vertex vert = new Vertex(o);
    vertices.add(vert);
    return vert;
  }

  void removeEdge(HalfEdge e) {
    e?.next?.prev = null;
    e?.prev?.next = null;
    e?.valid = false;
  }

  void removeVertex(Vertex v) {
    v?.valid = false;
  }

  void bindTo(Rectangle boundingBox) {
    if(edges.length == 0) {
      DoublyConnectedEdgeList d = DoublyConnectedEdgeList.fromRectangle(boundingBox, faces.first.center);
      edges = d.edges;
      vertices = d.vertices;
      _faces = d._faces;
      return;
    }

    // trim edges
    Clipper c = new Clipper(boundingBox);
    new List.from(edges.where((HalfEdge e) => c.isOutside(e.start, e.end)))..forEach(removeEdge);
    vertices.removeWhere((Vertex v) => !boundingBox.containsPoint(v.p.asPoint));
    _clean();
    edges.forEach(c.clip);

    // close edges
    HalfEdge start = edges.firstWhere((HalfEdge e) => e.prev == null);
    HalfEdge end = start;
    HalfEdge prev = null;
    do {
      HalfEdge curr = start;
      // find loose edge
      while (curr.next != null) {
        curr = curr.next;
      }

      HalfEdge e1 = newEdge();
      HalfEdge e2 = newTwinEdge(e1);
      e1.face = start.face;
      e2.face = NULL_FACE;
      e1.o = curr.twin.o;
      // deal with corner cases
      if (curr.end.x != start.start.x && curr.end.y != start.start.y) {
        HalfEdge e3 = newEdge();
        HalfEdge e4 = newTwinEdge(e3);
        e1.next = e3;
        e3.next = start;
        e3.face = start.face;
        e4.face = NULL_FACE;
        e4.o = start.o;
        curr.next = e1;
        Vertex cornerVertex = (curr.end.x > start.start.x) ?
            curr.end.y > start.start.y ?
                newVertex(new Vector2(curr.end.x, start.start.y)) :
                newVertex(new Vector2(start.start.x, curr.end.y)) :
            curr.end.y < start.start.y ?
                newVertex(new Vector2(curr.end.x, start.start.y)) :
                newVertex(new Vector2(start.start.x, curr.end.y));
        e2.o = cornerVertex;
        e3.o = cornerVertex;
        e4.next = e2;
        e4.prev = prev;
        prev = e2;
      } else { // non corner case
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
}

class HalfEdge {
  Vertex o; //origin
  HalfEdge _twin;
  Face _face;
  HalfEdge _next;
  HalfEdge _prev;

  bool valid = true;

  Face get face => _face;
  void set face(Face f) {
    _face = f;
    f._edge = this;
  }

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

  // tests is point [v] lies above this half edge
  // assumes edge is left to right
  bool pointLiesAbove(Vector2 v) {
    double m = (start.y - end.y) / (start.x - end.x);
    return v.y > m*v.x + start.y - m*start.x;
  }
}

class Face {
  // assume faces with more edges than this are infinite
  static int _EDGE_SIZE_LIMIT = 100;

  Vector2 center;
  HalfEdge _edge;

  HalfEdge get edge => _edge;

  void set edge(HalfEdge e) {
    _edge = e;
    e._face = this;
  }

  // do the edges form a loop
  bool get isClosed {
    HalfEdge start = _edge;
    HalfEdge curr = start;
    int countdown = _EDGE_SIZE_LIMIT;
    do {
      curr = curr.next;
      countdown--;
    } while(curr != null && curr != start && countdown > 0);

    start = _edge;
    curr = start;
    countdown = _EDGE_SIZE_LIMIT;
    do {
      curr = curr.prev;
      countdown--;
    } while(curr != null && curr != start && countdown > 0);
    return curr == start;
  }

  Face(this.center);

  String toString() => "Face at $center";
}

class NullFace extends Face {
  NullFace() : super(null);

  String toString() => "Null Face";
}

class Vertex {
  Vector2 p;
  HalfEdge e;

  bool valid = true;

  double get x => p.x;
  double get y => p.y;

  Vertex(this.p);
}
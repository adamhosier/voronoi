part of voronoi;

class DoublyConnectedEdgeList {
  List<Vertex> vertices = new List();
  List<HalfEdge> edges = new List();

  Map<Vector2, Face> _faces = new Map();
  List<Face> get faces => _faces.values.toList();

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
    edges.remove(e);
  }

  void removeVertex(Vertex v) {
    vertices.remove(v);
  }

  void bindTo(Rectangle boundingBox) {
    // trim edges
    Clipper c = new Clipper(boundingBox);
    edges.removeWhere((HalfEdge e) => c.isOutside(e.start, e.end));
    vertices.removeWhere((Vertex v) => !boundingBox.containsPoint(v.p.asPoint));
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
      e1.o = curr.twin.o;
      // deal with corner cases
      if (curr.end.x != start.start.x && curr.end.y != start.start.y) {
        HalfEdge e3 = newEdge();
        HalfEdge e4 = newTwinEdge(e3);
        e1.next = e3;
        e3.next = start;
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
  Vector2 center;
  HalfEdge edge;

  Face(this.center);
}

class Vertex {
  Vector2 p;
  HalfEdge e;

  Vertex(this.p);
}
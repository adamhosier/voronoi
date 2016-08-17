// Cohen-Sutherland clipping implementation
// Adam Hosier 2016

part of geometry;

class Clipper {

  static const int INSIDE = 0;
  static const int LEFT = 1;
  static const int RIGHT = 2;
  static const int BOTTOM = 4;
  static const int TOP = 8;

  Rectangle _r;

  Clipper(this._r);

  int getOutCode(Vector2 v) {
    int code = INSIDE;
    if(v.x < _r.left) code |= LEFT;
    if(v.x > _r.right) code |= RIGHT;
    if(v.y < _r.top) code |= TOP;
    if(v.y > _r.bottom) code |= BOTTOM;
    return code;
  }

  bool isOutside(Vector2 p1, Vector2 p2) {
    int o1 = getOutCode(p1);
    int o2 = getOutCode(p2);
    if((o1 | o2) == INSIDE) return false; // both points inside
    else if((o1 & o2) != 0) return true; // both points share a non-visable region
    else return false;
  }

  void clip(HalfEdge e) {
    while (true) {
      int code = getOutCode(e.start);
      if (code & Clipper.BOTTOM > 0) {
        e.o = new Vertex(new Vector2(e.start.x +
            (e.end.x - e.start.x) * (_r.bottom - e.start.y) /
                (e.end.y - e.start.y), _r.bottom));
        e.twin.next = null;
      } else if (code & Clipper.TOP > 0) {
        e.o = new Vertex(new Vector2(e.start.x +
            (e.end.x - e.start.x) * (_r.top - e.start.y) /
                (e.end.y - e.start.y), _r.top));
        e.twin.next = null;
      } else if (code & Clipper.LEFT > 0) {
        e.o = new Vertex(new Vector2(_r.left, e.start.y +
            (e.end.y - e.start.y) * (_r.left - e.start.x) /
                (e.end.x - e.start.x)));
        e.twin.next = null;
      } else if (code & Clipper.RIGHT > 0) {
        e.o = new Vertex(new Vector2(_r.right, e.start.y +
            (e.end.y - e.start.y) * (_r.right - e.start.x) /
                (e.end.x - e.start.x)));
        e.twin.next = null;
      } else {
        return;
      }
    }
  }

}
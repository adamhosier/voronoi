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

  // detects if the line joining p1 and p2 lays ouside the box
  bool isOutside(Vector2 p1, Vector2 p2) {
    Rectangle r = new Rectangle(min(p1.x, p2.x), min(p1.y, p2.y), (p1.x - p2.x).abs(), (p1.y - p2.y).abs());
    return !_r.containsRectangle(r) && !_r.intersects(r);
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
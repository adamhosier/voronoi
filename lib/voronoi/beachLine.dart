part of voronoi;

class BeachLine {
  LeafedTree<BeachInternalNode, BeachLeaf> _tree = new LeafedTree();
  LeafedTree get tree => _tree;

  bool get isEmpty => tree.isEmpty;

  // Finds all breakpoints on the beach line when the sweep line is in position [y]
  List<Vector2> getBreakpoints(double y) {
    return _tree.internalNodes.map((BeachInternalNode n) => calculateBreakpoint(n.a, n.b, y));
  }

  // Finds the leaf associated with site that has x coordinate [x], when the sweepline is at [y]
  BeachLeaf findLeaf(double x, double sweep) {
    return _tree.findLeaf(x, (BeachInternalNode node, double x) {
      return x < calculateBreakpoint(node.a, node.b, sweep).x;
    });
  }

  // Finds the internal node representing the breakpoint with x coordinate [x] when the sweepline is at [y]
  BeachInternalNode findInternalNode(double x, double sweep) {
    return _tree.findInternalNode(x, (BeachInternalNode node, double x) {
      double diff = x - calculateBreakpoint(node.a, node.b, sweep).x;
      return diff < -Voronoi.Epsilon ? -1 : (diff.abs() < Voronoi.Epsilon ? 0 : 1);
    });
  }

  Vector2 calculateBreakpoint(VoronoiSite aSite, VoronoiSite bSite, double sweep) {
    // transform into new plane
    Vector2 a = new Vector2(0.0, sweep - aSite.y);
    Vector2 b = new Vector2(bSite.x - aSite.x, sweep - bSite.y);

    // if point lies on sweep line
    if(b.y == 0) return new Vector2(bSite.x, sweep);
    if(a.y == 0) return new Vector2(aSite.x, sweep);
    if((a.y - b.y).abs() < Voronoi.Epsilon) return new Vector2((aSite.x + bSite.x) / 2, sweep);

    // calculate intersection
    double na = b.y - a.y;
    double nb = 2.0*b.x*a.y;
    double nc = a.y * b.y * (a.y - b.y) - b.x * b.x * a.y;
    double x = (-nb + sqrt(nb*nb - 4.0*na*nc)) / (2.0*na);
    double y = -(a.y * a.y + a.x * a.x - 2 * x * a.x + x * x) / (2 * a.y);
    Vector2 result = new Vector2(x, y);

    // transform back
    return result + new Vector2(aSite.x, sweep);
  }
}

class BeachInternalNode extends TreeInternalNode {
  VoronoiSite a, b;
  HalfEdge edge;
}

class BeachLeaf extends TreeLeaf {
  VoronoiSite site;
  VoronoiCircleEvent event;

  double get x => site.x;
  double get y => site.y;
  Vector2 get pos => new Vector2(x, y);
  bool get hasEvent => event != null;

  BeachLeaf(this.site);


  BeachLeaf clone() {
    BeachLeaf newLeaf = new BeachLeaf(this.site);
    newLeaf.parent = parent;
    newLeaf.event = event;
    return newLeaf;
  }
}
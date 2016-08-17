part of voronoi;

class BeachLine {
  BSTNode root;

  bool get isEmpty => root == null;
  bool get isNotEmpty => !isEmpty;

  // Gathers a list of all internal nodes, tree is walked in-order
  List<BSTInternalNode> get internalNodes {
    return _getInternalNodes(root);
  }

  List<BSTInternalNode> _getInternalNodes(BSTNode node) {
    if(node is BSTInternalNode) {
      List<BSTInternalNode> nodes = new List();
      nodes.addAll(_getInternalNodes(node.l));
      nodes.add(node);
      nodes.addAll(_getInternalNodes(node.r));
      return nodes;
    }
    return [];
  }

  // Finds all breakpoints on the beach line when the sweep line is in position [y]
  List<Vector2> getBreakpoints(double y) {
    return internalNodes.map((BSTInternalNode n) => findBreakpoint(n, y));
  }

  // Finds the leaf associated with site [s]
  BSTLeaf search(VoronoiSite s) {
    return _search(root, s);
  }

  BSTLeaf _search(BSTNode node, VoronoiSite s) {
    // for internal nodes, calculate breakpoint and compare it to s, then recurse accordingly
    if (node is BSTInternalNode) return _search(s.x < findBreakpoint(node, s.y).x ? node.l : node.r, s);

    // we must have hit a leaf (base case)
    return node;
  }

  // Searches the tree for the node that needs to be changed on a circle event
  BSTInternalNode findBrokenNode(Vector2 v, double sweep) {
    return _findBrokenNode(root, v, sweep);
  }

  BSTInternalNode _findBrokenNode(BSTNode node, Vector2 v, double sweep) {
    if(node is BSTInternalNode) {
      double diff = v.x - findBreakpoint(node, sweep).x;
      if(diff < -Voronoi.Epsilon) {
        return _findBrokenNode(node.l, v, sweep);
      } else if(diff.abs() < Voronoi.Epsilon) {
        return node;
      } else {
        return _findBrokenNode(node.r, v, sweep);
      }
    }
    return null;
  }

  Vector2 findBreakpoint(BSTInternalNode node, double sweep) {
    // transform into new plane
    Vector2 a = new Vector2(0.0, sweep - node.a.y);
    Vector2 b = new Vector2(node.b.x - node.a.x, sweep - node.b.y);

    // if point lies on sweep line
    if(b.y == 0) return new Vector2(node.b.x, sweep);
    if(a.y == 0) return new Vector2(node.a.x, sweep);
    if((a.y - b.y).abs() < Voronoi.Epsilon) return new Vector2((node.a.x + node.b.x) / 2, sweep);

    // calculate intersection
    double na = b.y - a.y;
    double nb = 2.0*b.x*a.y;
    double nc = a.y * b.y * (a.y - b.y) - b.x * b.x * a.y;
    double x = (-nb + sqrt(nb*nb - 4.0*na*nc)) / (2.0*na);
    double y = -(a.y * a.y + a.x * a.x - 2 * x * a.x + x * x) / (2 * a.y);
    Vector2 result = new Vector2(x, y);

    // transform back
    return result + new Vector2(node.a.x, sweep);
  }
}

abstract class BSTNode {
  BSTInternalNode parent;

  BSTLeaf get leftMostLeaf;
  BSTLeaf get rightMostLeaf;

  bool get hasParent => this.parent != null;

  BSTNode get brother {
    if(hasParent) {
      if(parent.r == this) return parent.l;
      else return parent.r;
    }
    return null;
  }

  BSTNode get uncle {
    if(hasParent && parent.hasParent) {
      if(parent.parent.r == parent) return parent.parent.l;
      else return parent.parent.r;
    }
    return null;
  }

  BSTLeaf get leftLeaf {
    if(hasParent) {
      if(parent.r == this) return parent.l.rightMostLeaf;
      else return parent.leftLeaf;
    }
    return null;
  }

  BSTLeaf get rightLeaf {
    if(hasParent) {
      if (parent.l == this) return parent.r.leftMostLeaf;
      else return parent.rightLeaf;
    }
    return null;
  }

}

class BSTInternalNode extends BSTNode {
  BSTNode _l, _r;
  VoronoiSite a, b;
  HalfEdge edge;

  BSTNode get l => _l;
  BSTNode get r => _r;

  BSTLeaf get leftMostLeaf => l.leftMostLeaf;
  BSTLeaf get rightMostLeaf => r.rightMostLeaf;

  void set l(BSTNode n) {
    n.parent = this;
    this._l = n;
  }

  void set r(BSTNode n) {
    n.parent = this;
    this._r = n;
  }

  bool isInRightSubtreeOf(BSTInternalNode root) {
    if(parent == root) {
      return parent.r == this;
    } else {
      return parent.isInRightSubtreeOf(root);
    }
  }

  bool isInLeftSubtreeOf(BSTInternalNode root) {
    if(parent == root) {
      return parent.l == this;
    } else {
      return parent.isInLeftSubtreeOf(root);
    }
  }
}

class BSTLeaf extends BSTNode {
  VoronoiSite site;
  VoronoiCircleEvent event;

  double get x => site.x;
  double get y => site.y;
  Vector2 get pos => new Vector2(x, y);
  bool get hasEvent => event == null;

  BSTLeaf get leftMostLeaf => this;
  BSTLeaf get rightMostLeaf => this;

  BSTLeaf(this.site);

  BSTLeaf clone() {
    BSTLeaf newLeaf = new BSTLeaf(this.site);
    newLeaf.parent = parent;
    newLeaf.event = event;
    return newLeaf;
  }
}
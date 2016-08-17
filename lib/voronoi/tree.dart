part of voronoi;

class BST {
  BSTNode root;

  BST();

  bool get isEmpty => root == null;
  bool get isNotEmpty => !isEmpty;

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

  getBreakpoints(double y) {
    return _findBreakpoints(root, y, []);
  }

  BSTLeaf search(VoronoiSite s) {
    return _search(root, s);
  }

  BSTLeaf _search(BSTNode node, VoronoiSite s) {
    if(node is BSTLeaf) {
      return node;
    } else if (node is BSTInternalNode){
      double x = _findBreakpoint(node.a, node.b, s.y).x;
      if(s.x < x) {
        return _search(node.l, s);
      } else {
        return _search(node.r, s);
      }
    }
    return null;
  }

  BSTInternalNode findBrokenNode(Vector2 v, double sweep) {
    return _findBrokenNode(root, v, sweep);
  }

  BSTInternalNode _findBrokenNode(BSTNode node, Vector2 v, double sweep) {
    if(node is BSTInternalNode) {
      double x = _findBreakpoint(node.a, node.b, sweep).x;
      double diff = v.x - x;
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
    return _findBreakpoint(node.a, node.b, sweep);
  }

  Vector2 _findBreakpoint(VoronoiSite aSite, VoronoiSite bSite, double sweep) {
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

  // EXPENSIVE - do not use this unless debugging
  List<Vector2> _findBreakpoints(BSTNode node, double y, List<Vector2> result) {
    if(node is BSTInternalNode) {
      _findBreakpoints(node.l, y, result);

      result.add(_findBreakpoint(node.a, node.b, y));

      _findBreakpoints(node.r, y, result);
    }
    return result;
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
    if(parent?.hasParent) {
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
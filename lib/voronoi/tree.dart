part of voronoi;

class BST {
  BSTNode root;

  BST();

  bool get isEmpty => root == null;
  bool get isNotEmpty => !isEmpty;

  BSTLeaf search(VoronoiSite s) {
    return _search(root, s);
  }

  BSTLeaf _search(BSTNode node, VoronoiSite s) {
    if(node is BSTLeaf) {
      return node;
    } else if (node is BSTInternalNode){
      double x = _findBreakpoint(node.a, node.b, s.y);
      if(s.x < x) {
        return _search(node.l, s);
      } else {
        return _search(node.r, s);
      }
    }
    return null;
  }

  double _findBreakpoint(VoronoiSite a, VoronoiSite b, double y) {
    return (a.y * b.x - sqrt(a.y * b.y * pow(a.y - b.y, 2) + pow(b.x, 2))) / (a.y - b.y);
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
  VoronoiSite a, b; //site
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


}

class BSTLeaf extends BSTNode {
  BSTInternalNode parent;
  VoronoiSite site;
  VoronoiCircleEvent event;

  double get x => site.x;
  double get y => site.y;
  Vector2 get pos => new Vector2(x, y);

  BSTLeaf get leftMostLeaf => this;
  BSTLeaf get rightMostLeaf => this;

  BSTLeaf(this.site);

  BSTLeaf clone() {
    BSTLeaf newLeaf = new BSTLeaf(this.site);
    newLeaf.parent = parent;
    return newLeaf;
  }
}
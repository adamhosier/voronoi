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
  BSTNode parent;
}

class BSTInternalNode extends BSTNode {
  BSTNode _l, _r;
  VoronoiSite a, b; //site
  _Edge edge;

  BSTNode get l => _l;
  BSTNode get r => _r;

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

  BSTLeaf(this.site);

  BSTLeaf clone() {
    BSTLeaf newLeaf = new BSTLeaf(this.site);
    newLeaf.parent = parent;
    return newLeaf;
  }
}
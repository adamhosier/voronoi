class LeafedTree<S extends TreeInternalNode,T extends TreeLeaf> {
  S root;

  bool get isEmpty => root == null;
  bool get isNotEmpty => !isEmpty;

  // Gathers a list of all internal nodes, tree is walked in-order
  List<S> get internalNodes => _getInternalNodes(root);

  List<S> _getInternalNodes(TreeNode node) {
    if(node is TreeInternalNode) {
      List<S> nodes = new List();
      nodes.addAll(_getInternalNodes(node.l));
      nodes.add(node);
      nodes.addAll(_getInternalNodes(node.r));
      return nodes;
    }
    return [];
  }

  // Traverses the tree, branching based on the comparator function, until a leaf is found
  T findLeaf(double x, Function comparator) {
    return _findLeaf(root, x, comparator);
  }

  T _findLeaf(TreeNode node, double x, Function comparator) {
    // branch by evaluating comparator
    if(node is TreeInternalNode) {
      return _findLeaf(comparator(node, x) ? node.l : node.r, x, comparator);
    }
    // otherwise we have hit a leaf
    return node as T;
  }

  // Traverses the tree, branching based on the comparator function, until a matching internal node is found
  S findInternalNode(double x, Function comparator) {
    return _findInternalNode(root, x, comparator);
  }

  S _findInternalNode(TreeNode node, double x, Function comparator) {
    if(node is TreeInternalNode) {
      int comp = comparator(node, x);
      if(comp < 0) {
        return _findInternalNode(node.l, x, comparator);
      } else if(comp == 0) {
        return node;
      } else {
        return _findInternalNode(node.r, x, comparator);
      }
    }
    throw new Exception("No internal node with x=$x found");
  }


  void clear() {
    root = null;
  }
}

abstract class TreeNode {
  TreeInternalNode parent;

  TreeLeaf get leftMostLeaf;
  TreeLeaf get rightMostLeaf;

  bool get hasParent => this.parent != null;

  TreeNode get brother {
    if(hasParent) {
      if(parent.r == this) return parent.l;
      else return parent.r;
    }
    return null;
  }

  TreeNode get uncle {
    if(hasParent && parent.hasParent) {
      if(parent.parent.r == parent) return parent.parent.l;
      else return parent.parent.r;
    }
    return null;
  }

  TreeLeaf get leftLeaf {
    if(hasParent) {
      if(parent.r == this) return parent.l.rightMostLeaf;
      else return parent.leftLeaf;
    }
    return null;
  }

  TreeLeaf get rightLeaf {
    if(hasParent) {
      if (parent.l == this) return parent.r.leftMostLeaf;
      else return parent.rightLeaf;
    }
    return null;
  }

}

class TreeInternalNode extends TreeNode {
  TreeNode _l, _r;

  TreeNode get l => _l;
  void set l(TreeNode n) {
    n.parent = this;
    this._l = n;
  }

  TreeNode get r => _r;
  void set r(TreeNode n) {
    n.parent = this;
    this._r = n;
  }

  TreeLeaf get leftMostLeaf => l.leftMostLeaf;
  TreeLeaf get rightMostLeaf => r.rightMostLeaf;

  // tests if this is in the right subtree of [root]
  bool isInRightSubtreeOf(TreeInternalNode root) {
    if(parent == root) {
      return parent.r == this;
    } else {
      return parent.isInRightSubtreeOf(root);
    }
  }

  bool isInLeftSubtreeOf(TreeInternalNode root) {
    if(parent == root) {
      return parent.l == this;
    } else {
      return parent.isInLeftSubtreeOf(root);
    }
  }
}

class TreeLeaf extends TreeNode {
  TreeLeaf get leftMostLeaf => this;
  TreeLeaf get rightMostLeaf => this;
}

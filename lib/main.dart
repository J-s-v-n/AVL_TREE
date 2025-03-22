import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class AVLTreePainter extends CustomPainter {
  final Node? root;

  AVLTreePainter(this.root);

  @override
  void paint(Canvas canvas, Size size) {
    if (root != null) {
      _drawNode(canvas, root, size.width / 2, 40, size.width / 4);
    }
  }

  void _drawNode(Canvas canvas, Node? node, double x, double y, double xOffset) {
    if (node == null) return;

    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(x, y), 20, paint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${node.key}',
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));

    if (node.left != null) {
      canvas.drawLine(
        Offset(x, y + 20),
        Offset(x - xOffset, y + 80),
        Paint()..color = Colors.black,
      );
      _drawNode(canvas, node.left, x - xOffset, y + 100, xOffset / 2);
    }

    if (node.right != null) {
      canvas.drawLine(
        Offset(x, y + 20),
        Offset(x + xOffset, y + 80),
        Paint()..color = Colors.black,
      );
      _drawNode(canvas, node.right, x + xOffset, y + 100, xOffset / 2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AVL Tree Visualization',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AVLTreePage(),
    );
  }
}

class AVLTreePage extends StatefulWidget {
  const AVLTreePage({Key? key}) : super(key: key);

  @override
  _AVLTreePageState createState() => _AVLTreePageState();
}

class _AVLTreePageState extends State<AVLTreePage> {
  final TextEditingController _controller = TextEditingController();
  final AVLTree _tree = AVLTree();

  void _insertValue() {
    String value = _controller.text;
    if (value.isNotEmpty) {
      int key = int.tryParse(value) ?? 0;
      _tree.insertKey(key);
      _controller.clear();
      setState(() {});
    }
  }

  void _deleteValue() {
    String value = _controller.text;
    if (value.isNotEmpty) {
      int key = int.tryParse(value) ?? 0;
      _tree.deleteKey(key);
      _controller.clear();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AVL TREE')),
      backgroundColor: const Color.fromARGB(255, 248, 247, 249),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'Value'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _insertValue, child: const Text('Insert')),
                const SizedBox(width: 10),
                ElevatedButton(onPressed: _deleteValue, child: const Text('Delete')),
              ],
            ),
          ),
          Expanded(
            child: CustomPaint(
              painter: AVLTreePainter(_tree.root),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

class Node {
  int key;
  Node? left, right;
  int height;

  Node(this.key) : height = 1;
}

class AVLTree {
  Node? root;

  int height(Node? node) => node?.height ?? 0;
  int balanceFactor(Node? node) => height(node?.left) - height(node?.right);

  Node? rightRotate(Node? y) {
    Node? x = y?.left;
    Node? T2 = x?.right;
    x?.right = y;
    y?.left = T2;
    y?.height = max(height(y?.left), height(y?.right)) + 1;
    x?.height = max(height(x?.left), height(x?.right)) + 1;
    return x;
  }

  Node? leftRotate(Node? x) {
    Node? y = x?.right;
    Node? T2 = y?.left;
    y?.left = x;
    x?.right = T2;
    x?.height = max(height(x?.left), height(x?.right)) + 1;
    y?.height = max(height(y?.left), height(y?.right)) + 1;
    return y;
  }

  Node? insert(Node? node, int key) {
    if (node == null) return Node(key);

    if (key < node.key) {
      node.left = insert(node.left, key);
    } else if (key > node.key) {
      node.right = insert(node.right, key);
    } else {
      return node;
    }

    node.height = max(height(node.left), height(node.right)) + 1;
    int balance = balanceFactor(node);

    if (balance > 1 && key < node.left!.key) return rightRotate(node);
    if (balance < -1 && key > node.right!.key) return leftRotate(node);
    if (balance > 1 && key > node.left!.key) {
      node.left = leftRotate(node.left);
      return rightRotate(node);
    }
    if (balance < -1 && key < node.right!.key) {
      node.right = rightRotate(node.right);
      return leftRotate(node);
    }
    return node;
  }

  void insertKey(int key) {
    root = insert(root, key);
  }

  void deleteKey(int key) {
    root = delete(root, key);
  }

  Node? delete(Node? root, int key) {
    if (root == null) return null;
    if (key < root.key) {
      root.left = delete(root.left, key);
    } else if (key > root.key) {
      root.right = delete(root.right, key);
    } else {
      if (root.left == null) return root.right;
      if (root.right == null) return root.left;
      Node? temp = minValueNode(root.right);
      root.key = temp!.key;
      root.right = delete(root.right, temp.key);
    }

    root.height = 1 + max(height(root.left), height(root.right));
    int balance = balanceFactor(root);

    if (balance > 1 && balanceFactor(root.left) >= 0) return rightRotate(root);
    if (balance > 1 && balanceFactor(root.left) < 0) {
      root.left = leftRotate(root.left);
      return rightRotate(root);
    }
    if (balance < -1 && balanceFactor(root.right) <= 0) return leftRotate(root);
    if (balance < -1 && balanceFactor(root.right) > 0) {
      root.right = rightRotate(root.right);
      return leftRotate(root);
    }

    return root;
  }

  Node? minValueNode(Node? node) {
    Node? current = node;
    while (current?.left != null) {
      current = current?.left;
    }
    return current;
  }
}

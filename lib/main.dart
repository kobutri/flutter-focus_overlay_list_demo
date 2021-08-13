import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vecmath;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Material App Bar'),
        ),
        body: const Center(
          child: FocusList(),
        ),
      ),
    );
  }
}

class FocusList extends StatefulWidget {
  const FocusList({Key? key}) : super(key: key);

  @override
  State<FocusList> createState() => _FocusListState();
}

class _FocusListState extends State<FocusList> {
  var hover = -1;
  Widget? focused;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        return Center(
          child: FocusListItem(),
        );
      },
      itemCount: 20,
      scrollDirection: Axis.horizontal,
    );
  }
}

class FocusListItem extends StatefulWidget {
  FocusListItem({Key? key}) : super(key: key);

  @override
  _FocusListItemState createState() => _FocusListItemState();
}

class _FocusListItemState extends State<FocusListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  final _color =
      Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  final LayerLink _layerLink = LayerLink();
  final GlobalKey _containerKey = GlobalKey();
  var insertedOverlay = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _controller.addListener(() {
      setState(() {});
      _overlayEntry!.markNeedsBuild();
    });
    // _animation = Tween(
    //         begin: Matrix4.identity(),
    //         end: Matrix4.compose(vecmath.Vector3(0, 0, 5),
    //             vecmath.Quaternion.identity(), vecmath.Vector3(1.5, 1.5, 1)))
    //     .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
    _animation = Tween(begin: 1.0, end: 1.5)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.ease));
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(link: _layerLink, child: _build(false));
  }

  Widget _build(bool overlay) {
    return MouseRegion(
      onHover: (event) {
        if (!insertedOverlay && !overlay) {
          _overlayEntry = _createOverLayEntry();
          Overlay.of(context)!.insert(_overlayEntry!);
          _controller.forward();
          insertedOverlay = true;
        }
      },
      onExit: (event) async {
        if (insertedOverlay && overlay) {
          await _controller.reverse();
          _overlayEntry!.remove();
          insertedOverlay = false;
        }
      },
      child: Container(
        key: overlay ? null : _containerKey,
        width: 200,
        height: 100,
        color: _color,
        transformAlignment: Alignment.center,
        transform: Matrix4.compose(
          vecmath.Vector3.zero(),
          vecmath.Quaternion.identity(),
          vecmath.Vector3.all(_animation.value),
        ),
      ),
    );
  }

  OverlayEntry _createOverLayEntry() {
    var size = _containerKey.currentContext!.size;

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: size!.width,
          height: size.height,
          child: CompositedTransformFollower(
            link: _layerLink,
            child: _build(true),
          ),
        );
      },
    );
  }
}

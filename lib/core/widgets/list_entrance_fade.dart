import 'package:flutter/material.dart';

/// Fades and slides a list item up as it first appears, instead of it
/// popping in instantly. Staggers by [index] so items cascade in.
class ListEntranceFade extends StatefulWidget {
  const ListEntranceFade({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  static const _stagger = Duration(milliseconds: 35);
  static const _maxStaggerIndex = 6;

  @override
  State<ListEntranceFade> createState() => _ListEntranceFadeState();
}

class _ListEntranceFadeState extends State<ListEntranceFade> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    final delay = ListEntranceFade._stagger *
        widget.index.clamp(0, ListEntranceFade._maxStaggerIndex);
    Future.delayed(delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _visible ? Offset.zero : const Offset(0, 0.06),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

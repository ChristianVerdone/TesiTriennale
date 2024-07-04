import 'package:flutter/material.dart';

class ScrollableWidget extends StatelessWidget {
  final Widget child;
  final ScrollController controller;

  const ScrollableWidget({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    controller: controller,
    physics: const BouncingScrollPhysics(),
    scrollDirection: Axis.horizontal,
    child: SingleChildScrollView(
      controller: ScrollController(),
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: child,
    ),
  );
}
import 'package:flutter/material.dart';

class AlwaysVisibleScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Scrollbar buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return Scrollbar(
      thumbVisibility: true,
      controller: details.controller,
      child: child,
    );
  }
}

class ScrollableWidget extends StatelessWidget {
  final Widget child;
  final ScrollController controller;

  const ScrollableWidget({
    super.key,
    required this.child,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) => ScrollConfiguration(
    behavior: AlwaysVisibleScrollBehavior(),
    child: SingleChildScrollView(
      controller: controller,
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        controller: ScrollController(),
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: child,
      ),
    ),
  );
}
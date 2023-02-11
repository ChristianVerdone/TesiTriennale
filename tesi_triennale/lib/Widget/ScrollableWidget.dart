import 'package:flutter/material.dart';

class ScrollableWidget extends StatelessWidget {
  final Widget child;
  final ScrollController controller1 = ScrollController();
  final ScrollController controller2 = ScrollController();

   ScrollableWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Scrollbar(
    controller: controller2,
    thumbVisibility: false,
    child: SingleChildScrollView(
      controller: controller1,
      child: child,
    ),
  );
}
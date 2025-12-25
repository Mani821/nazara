import 'package:flutter/gestures.dart';
import 'package:nazara/common_libs.dart';
import 'package:nazara/ui/common/controls/trackpad_listener.dart';

class EightWaySwipeDetector extends StatefulWidget {
  const EightWaySwipeDetector({
    super.key,
    required this.child,
    this.threshold = 50,
    required this.onSwipe,
  });
  final Widget child;
  final double threshold;
  final void Function(Offset dir)? onSwipe;

  @override
  State<EightWaySwipeDetector> createState() => _EightWaySwipeDetectorState();
}

class _EightWaySwipeDetectorState extends State<EightWaySwipeDetector> {
  Offset _startPos = Offset.zero;
  Offset _endPos = Offset.zero;
  bool _isSwiping = false;

  void _resetSwipe() {
    _startPos = _endPos = Offset.zero;
    _isSwiping = false;
  }

  void _maybeTriggerSwipe() {
    // Exit early if we're not currently swiping :boom
    if (_isSwiping == false) return;
    // Get the distance of the swipe
    Offset moveDelta = _endPos - _startPos;
    final distance = moveDelta.distance;
    if (distance >= max(widget.threshold, 1)) {
      moveDelta /= distance;
      Offset dir = Offset(
        moveDelta.dx.roundToDouble(),
        moveDelta.dy.roundToDouble(),
      );
      widget.onSwipe?.call(dir);
      _resetSwipe();
    }
  }

  void _trackpadSwipe(Offset delta) {
    widget.onSwipe?.call(delta);
  }

  void _handleSwipeStart(DragStartDetails d) {
    _isSwiping = d.kind != null;
    _startPos = _endPos = d.localPosition;
  }

  void _handleSwipeUpdate(DragUpdateDetails d) {
    _endPos = d.localPosition;
    _maybeTriggerSwipe();
  }

  void _handleSwipeEnd(d) {
    _maybeTriggerSwipe();
    _resetSwipe();
  }

  @override
  Widget build(BuildContext context) {
    return TrackpadListener(
      scrollSensitivity: 70,
      onScroll: _trackpadSwipe,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onPanStart: _handleSwipeStart,
        onPanUpdate: _handleSwipeUpdate,
        onPanCancel: _resetSwipe,
        onPanEnd: _handleSwipeEnd,
        supportedDevices: const {
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.touch,
          PointerDeviceKind.unknown,
        },
        child: widget.child,
      ),
    );
  }
}

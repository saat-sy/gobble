import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const Curve _kResizeTimeCurve = Interval(0.4, 1.0, curve: Curves.ease);
const double _kMinFlingVelocity = 700.0;
const double _kMinFlingVelocityDelta = 400.0;
const double _kFlingVelocityScale = 1.0 / 300.0;
const double _kDismissThreshold = 0.4;

typedef DismissDirectionCallback = void Function(MyDismissDirection direction);

typedef ConfirmDismissCallback = bool? Function(MyDismissDirection direction);

typedef DismissUpdateCallback = void Function(DismissUpdateDetails details);

enum MyDismissDirection {
  vertical,
  horizontal,
  endToStart,
  startToEnd,
  up,
  down,
  none,
  // CUSTOM ONES
  all,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  left,
  right,
  top,
  bottom,
}

class MyDismissible extends StatefulWidget {
  MyDismissible({
    required Key key,
    required this.child,
    this.background,
    this.secondaryBackground,
    this.confirmDismiss,
    this.onResize,
    this.onUpdate,
    this.onDismissed,
    this.direction = MyDismissDirection.horizontal,
    this.resizeDuration = const Duration(milliseconds: 300),
    this.dismissThresholds = const <MyDismissDirection, double>{},
    this.movementDuration = const Duration(milliseconds: 200),
    this.crossAxisEndOffset = 0.0,
    this.dragStartBehavior = DragStartBehavior.start,
    this.behavior = HitTestBehavior.opaque,
  })  : assert(key != null),
        assert(secondaryBackground == null || background != null),
        assert(dragStartBehavior != null),
        super(key: key);

  final Widget child;

  final Widget? background;

  final Widget? secondaryBackground;

  final ConfirmDismissCallback? confirmDismiss;

  final VoidCallback? onResize;

  final DismissDirectionCallback? onDismissed;

  MyDismissDirection direction;

  final Duration? resizeDuration;

  final Map<MyDismissDirection, double> dismissThresholds;

  final Duration movementDuration;

  final double crossAxisEndOffset;

  final DragStartBehavior dragStartBehavior;

  final HitTestBehavior behavior;

  final DismissUpdateCallback? onUpdate;

  @override
  State<MyDismissible> createState() => _MyDismissibleState();
}

class DismissUpdateDetails {
  DismissUpdateDetails(
      {this.direction = MyDismissDirection.horizontal,
      this.reached = false,
      this.previousReached = false,
      required this.percentageCompleted});

  final MyDismissDirection direction;

  final bool reached;

  final bool previousReached;

  final double percentageCompleted;
}

class _DismissibleClipper extends CustomClipper<Rect> {
  _DismissibleClipper({
    required this.axis,
    required this.moveAnimation,
  })  : assert(axis != null),
        assert(moveAnimation != null),
        super(reclip: moveAnimation);

  final Axis axis;
  final Animation<Offset> moveAnimation;

  // FROM MY JAASOOSI, THIS IS CALLED EVERY TIME THE GESTURE IS DETECTED
  // AND IT RETURNS A RECT OF THE NEW POSITION

  @override
  Rect getClip(Size size) {
    assert(axis != null);
    switch (axis) {
      case Axis.horizontal:
        final double offset = moveAnimation.value.dx * size.width;
        if (offset < 0) {
          return Rect.fromLTRB(
              size.width + offset, 0.0, size.width, size.height);
        }
        return Rect.fromLTRB(0.0, 0.0, offset, size.height);
      case Axis.vertical:
        final double offset = moveAnimation.value.dy * size.height;
        if (offset < 0) {
          return Rect.fromLTRB(
              0.0, size.height + offset, size.width, size.height);
        }
        return Rect.fromLTRB(0.0, 0.0, size.width, offset);
    }
  }

  @override
  Rect getApproximateClipRect(Size size) => getClip(size);

  @override
  bool shouldReclip(_DismissibleClipper oldClipper) {
    return oldClipper.axis != axis ||
        oldClipper.moveAnimation.value != moveAnimation.value;
  }
}

enum _FlingGestureKind { none, forward, reverse }

class _MyDismissibleState extends State<MyDismissible>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final MyDismissDirection copyOfDirection;

  @override
  void initState() {
    super.initState();
    copyOfDirection = widget.direction;
    _moveController =
        AnimationController(duration: widget.movementDuration, vsync: this)
          ..addStatusListener(_handleDismissStatusChanged)
          ..addListener(_handleDismissUpdateValueChanged);
    _updateMoveAnimation();
  }

  AnimationController? _moveController;
  late Animation<Offset> _moveAnimation;

  AnimationController? _resizeController;
  Animation<double>? _resizeAnimation;

  double _dragExtent = 0.0;
  bool _confirming = false;
  bool _dragUnderway = false;
  Size? _sizePriorToCollapse;
  bool _dismissThresholdReached = false;

  @override
  bool get wantKeepAlive =>
      _moveController?.isAnimating == true ||
      _resizeController?.isAnimating == true;

  @override
  void dispose() {
    _moveController!.dispose();
    _resizeController?.dispose();
    super.dispose();
  }

  bool get _directionIsXAxis {
    return widget.direction == MyDismissDirection.horizontal ||
        widget.direction == MyDismissDirection.endToStart ||
        widget.direction == MyDismissDirection.startToEnd;
  }

  MyDismissDirection _extentToDirection(double extent) {
    if (extent == 0.0) {
      return MyDismissDirection.none;
    }
    if (_directionIsXAxis) {
      switch (Directionality.of(context)) {
        case TextDirection.rtl:
          return extent < 0
              ? MyDismissDirection.startToEnd
              : MyDismissDirection.endToStart;
        case TextDirection.ltr:
          return extent > 0
              ? MyDismissDirection.startToEnd
              : MyDismissDirection.endToStart;
      }
    }
    return extent > 0 ? MyDismissDirection.down : MyDismissDirection.up;
  }

  MyDismissDirection get _dismissDirection => _extentToDirection(_dragExtent);

  bool get _isActive {
    return _dragUnderway || _moveController!.isAnimating;
  }

  double get _overallDragAxisExtent {
    final Size size = context.size!;
    return _directionIsXAxis ? size.width : size.height;
  }

  void _handleDragStart(DragStartDetails details) {
    if (_confirming) {
      return;
    }
    _dragUnderway = true;
    if (_moveController!.isAnimating) {
      _dragExtent =
          _moveController!.value * _overallDragAxisExtent * _dragExtent.sign;
      _moveController!.stop();
    } else {
      _dragExtent = 0.0;
      _moveController!.value = 0.0;
    }
    setState(() {
      _updateMoveAnimation();
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isActive || _moveController!.isAnimating) {
      return;
    }

    final double delta = details.primaryDelta!;
    final double oldDragExtent = _dragExtent;
    switch (widget.direction) {
      case MyDismissDirection.horizontal:
      case MyDismissDirection.vertical:
        _dragExtent += delta;
        break;

      case MyDismissDirection.up:
        if (_dragExtent + delta < 0) {
          _dragExtent += delta;
        }
        break;

      case MyDismissDirection.down:
        if (_dragExtent + delta > 0) {
          _dragExtent += delta;
        }
        break;

      case MyDismissDirection.endToStart:
        switch (Directionality.of(context)) {
          case TextDirection.rtl:
            if (_dragExtent + delta > 0) {
              _dragExtent += delta;
            }
            break;
          case TextDirection.ltr:
            if (_dragExtent + delta < 0) {
              _dragExtent += delta;
            }
            break;
        }
        break;

      case MyDismissDirection.startToEnd:
        switch (Directionality.of(context)) {
          case TextDirection.rtl:
            if (_dragExtent + delta < 0) {
              _dragExtent += delta;
            }
            break;
          case TextDirection.ltr:
            if (_dragExtent + delta > 0) {
              _dragExtent += delta;
            }
            break;
        }
        break;

      case MyDismissDirection.none:
        _dragExtent = 0;
        break;

      case MyDismissDirection.all:
        _dragExtent += delta;
        break;

      default:
        break;
    }
    if (oldDragExtent.sign != _dragExtent.sign) {
      setState(() {
        _updateMoveAnimation();
      });
    }
    if (!_moveController!.isAnimating) {
      _moveController!.value = _dragExtent.abs() / _overallDragAxisExtent;
    }

    // TODO: DO SOMETHING WITH THE VALUE
    // print(_dragExtent);
  }

  void _handleDismissUpdateValueChanged() {
    if (widget.onUpdate != null) {
      final bool oldDismissThresholdReached = _dismissThresholdReached;
      _dismissThresholdReached = _moveController!.value >
          (widget.dismissThresholds[_dismissDirection] ?? _kDismissThreshold);
      final DismissUpdateDetails details = DismissUpdateDetails(
          direction: _dismissDirection,
          reached: _dismissThresholdReached,
          previousReached: oldDismissThresholdReached,
          percentageCompleted: _moveController!.value);
      widget.onUpdate!(details);
    }
  }

  void _updateMoveAnimation() {
    final double end = _dragExtent.sign;
    _moveAnimation = _moveController!.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: _directionIsXAxis
            ? Offset(end, widget.crossAxisEndOffset)
            : Offset(widget.crossAxisEndOffset, end),
      ),
    );
  }

  _FlingGestureKind _describeFlingGesture(Velocity velocity) {
    assert(widget.direction != null);
    if (_dragExtent == 0.0) {
      return _FlingGestureKind.none;
    }
    final double vx = velocity.pixelsPerSecond.dx;
    final double vy = velocity.pixelsPerSecond.dy;
    MyDismissDirection flingDirection;
    // Verify that the fling is in the generally right direction and fast enough.
    if (_directionIsXAxis) {
      if (vx.abs() - vy.abs() < _kMinFlingVelocityDelta ||
          vx.abs() < _kMinFlingVelocity) {
        return _FlingGestureKind.none;
      }
      assert(vx != 0.0);
      flingDirection = _extentToDirection(vx);
    } else {
      if (vy.abs() - vx.abs() < _kMinFlingVelocityDelta ||
          vy.abs() < _kMinFlingVelocity) {
        return _FlingGestureKind.none;
      }
      assert(vy != 0.0);
      flingDirection = _extentToDirection(vy);
    }
    assert(_dismissDirection != null);
    if (flingDirection == _dismissDirection) {
      return _FlingGestureKind.forward;
    }
    return _FlingGestureKind.reverse;
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isActive || _moveController!.isAnimating) {
      return;
    }
    _dragUnderway = false;
    if (_moveController!.isCompleted) {
      _handleMoveCompleted();
      return;
    }
    final double flingVelocity = _directionIsXAxis
        ? details.velocity.pixelsPerSecond.dx
        : details.velocity.pixelsPerSecond.dy;
    switch (_describeFlingGesture(details.velocity)) {
      case _FlingGestureKind.forward:
        assert(_dragExtent != 0.0);
        assert(!_moveController!.isDismissed);
        if ((widget.dismissThresholds[_dismissDirection] ??
                _kDismissThreshold) >=
            1.0) {
          _moveController!.reverse();
          break;
        }
        _dragExtent = flingVelocity.sign;
        _moveController!
            .fling(velocity: flingVelocity.abs() * _kFlingVelocityScale);
        break;
      case _FlingGestureKind.reverse:
        assert(_dragExtent != 0.0);
        assert(!_moveController!.isDismissed);
        _dragExtent = flingVelocity.sign;
        _moveController!
            .fling(velocity: -flingVelocity.abs() * _kFlingVelocityScale);
        break;
      case _FlingGestureKind.none:
        if (!_moveController!.isDismissed) {
          // we already know it's not completed, we check that above
          if (_moveController!.value >
              (widget.dismissThresholds[_dismissDirection] ??
                  _kDismissThreshold)) {
            _moveController!.forward();
          } else {
            _moveController!.reverse();
          }
        }
        break;
    }
  }

  Future<void> _handleDismissStatusChanged(AnimationStatus status) async {
    if (status == AnimationStatus.completed && !_dragUnderway) {
      await _handleMoveCompleted();
    }
    if (mounted) {
      updateKeepAlive();
    }
  }

  Future<void> _handleMoveCompleted() async {
    if ((widget.dismissThresholds[_dismissDirection] ?? _kDismissThreshold) >=
        1.0) {
      _moveController!.reverse();
      return;
    }
    final bool result = await _confirmStartResizeAnimation();
    if (mounted) {
      if (result) {
        _startResizeAnimation();
      } else {
        _moveController!.reverse();
      }
    }
  }

  Future<bool> _confirmStartResizeAnimation() async {
    if (widget.confirmDismiss != null) {
      _confirming = true;
      final MyDismissDirection direction = _dismissDirection;
      try {
        return widget.confirmDismiss!(direction) ?? false;
      } finally {
        _confirming = false;
      }
    }
    return true;
  }

  void _startResizeAnimation() {
    assert(_moveController!.isCompleted);
    assert(_resizeController == null);
    assert(_sizePriorToCollapse == null);
    if (widget.resizeDuration == null) {
      if (widget.onDismissed != null) {
        final MyDismissDirection direction = _dismissDirection;
        widget.onDismissed!(direction);
      }
    } else {
      _resizeController =
          AnimationController(duration: widget.resizeDuration, vsync: this)
            ..addListener(_handleResizeProgressChanged)
            ..addStatusListener((AnimationStatus status) => updateKeepAlive());
      _resizeController!.forward();
      setState(() {
        _sizePriorToCollapse = context.size;
        _resizeAnimation = _resizeController!
            .drive(
              CurveTween(
                curve: _kResizeTimeCurve,
              ),
            )
            .drive(
              Tween<double>(
                begin: 1.0,
                end: 0.0,
              ),
            );
      });
    }
  }

  void _handleResizeProgressChanged() {
    if (_resizeController!.isCompleted) {
      widget.onDismissed?.call(_dismissDirection);
    } else {
      widget.onResize?.call();
    }
  }

  bool _isDirectionCustom() {
    return copyOfDirection == MyDismissDirection.all ||
        copyOfDirection == MyDismissDirection.topLeft ||
        copyOfDirection == MyDismissDirection.topRight ||
        copyOfDirection == MyDismissDirection.bottomLeft ||
        copyOfDirection == MyDismissDirection.bottomRight ||
        copyOfDirection == MyDismissDirection.left ||
        copyOfDirection == MyDismissDirection.right ||
        copyOfDirection == MyDismissDirection.top ||
        copyOfDirection == MyDismissDirection.bottom;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.

    assert(!_directionIsXAxis || debugCheckHasDirectionality(context));

    Widget? background = widget.background;
    if (widget.secondaryBackground != null) {
      final MyDismissDirection direction = _dismissDirection;
      if (direction == MyDismissDirection.endToStart ||
          direction == MyDismissDirection.up) {
        background = widget.secondaryBackground;
      }
    }

    if (_resizeAnimation != null) {
      // we've been dragged aside, and are now resizing.
      assert(() {
        if (_resizeAnimation!.status != AnimationStatus.forward) {
          assert(_resizeAnimation!.status == AnimationStatus.completed);
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
                'A dismissed Dismissible widget is still part of the tree.'),
            ErrorHint(
              'Make sure to implement the onDismissed handler and to immediately remove the Dismissible '
              'widget from the application once that handler has fired.',
            ),
          ]);
        }
        return true;
      }());

      return SizeTransition(
        sizeFactor: _resizeAnimation!,
        axis: _directionIsXAxis ? Axis.vertical : Axis.horizontal,
        child: SizedBox(
          width: _sizePriorToCollapse!.width,
          height: _sizePriorToCollapse!.height,
          child: background,
        ),
      );
    }

    Widget content = SlideTransition(
      position: _moveAnimation,
      child: widget.child,
    );

    if (background != null) {
      content = Stack(children: <Widget>[
        if (!_moveAnimation.isDismissed)
          Positioned.fill(
            child: ClipRect(
              clipper: _DismissibleClipper(
                axis: _directionIsXAxis ? Axis.horizontal : Axis.vertical,
                moveAnimation: _moveAnimation,
              ),
              child: background,
            ),
          ),
        content,
      ]);
    }

    // If the DismissDirection is none, we do not add drag gestures because the content
    // cannot be dragged.
    if (widget.direction == MyDismissDirection.none) {
      return content;
    }

    if (_isDirectionCustom()) {
      return GestureDetector(
        onHorizontalDragStart: ((details) {
          switch (copyOfDirection) {
            case MyDismissDirection.all:
            case MyDismissDirection.top:
            case MyDismissDirection.bottom:
              widget.direction = MyDismissDirection.horizontal;
              break;

            case MyDismissDirection.topLeft:
            case MyDismissDirection.left:
            case MyDismissDirection.bottomLeft:
              widget.direction = MyDismissDirection.startToEnd;
              break;

            case MyDismissDirection.topRight:
            case MyDismissDirection.bottomRight:
            case MyDismissDirection.right:
              widget.direction = MyDismissDirection.endToStart;
              break;

            default:
              break;
          }
          _handleDragStart(details);
        }),
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        onVerticalDragStart: ((details) {
          switch (copyOfDirection) {
            case MyDismissDirection.all:
            case MyDismissDirection.left:
            case MyDismissDirection.right:
              widget.direction = MyDismissDirection.vertical;
              break;

            case MyDismissDirection.bottomLeft:
            case MyDismissDirection.bottomRight:
            case MyDismissDirection.bottom:
              widget.direction = MyDismissDirection.up;
              break;

            case MyDismissDirection.topRight:
            case MyDismissDirection.topLeft:
            case MyDismissDirection.top:
              widget.direction = MyDismissDirection.down;
              break;

            default:
              break;
          }
          _handleDragStart(details);
        }),
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: _handleDragEnd,
        behavior: widget.behavior,
        dragStartBehavior: widget.dragStartBehavior,
        child: content,
      );
    }

    // We are not resizing but we may be being dragging in widget.direction.
    return GestureDetector(
      onHorizontalDragStart: _directionIsXAxis ? _handleDragStart : null,
      onHorizontalDragUpdate: _directionIsXAxis ? _handleDragUpdate : null,
      onHorizontalDragEnd: _directionIsXAxis ? _handleDragEnd : null,
      onVerticalDragStart: _directionIsXAxis ? null : _handleDragStart,
      onVerticalDragUpdate: _directionIsXAxis ? null : _handleDragUpdate,
      onVerticalDragEnd: _directionIsXAxis ? null : _handleDragEnd,
      behavior: widget.behavior,
      dragStartBehavior: widget.dragStartBehavior,
      child: content,
    );
  }
}

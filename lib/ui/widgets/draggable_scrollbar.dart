import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nautilus_wallet_flutter/service_locator.dart';
import 'package:nautilus_wallet_flutter/ui/widgets/custom_stack.dart';
import 'package:nautilus_wallet_flutter/util/hapticutil.dart';

class DraggableScrollbar extends StatefulWidget {
  const DraggableScrollbar(
      {this.scrollbarHeight = 60.0,
      this.scrollbarTopMargin = 10.0,
      this.scrollbarBottomMargin = 10.0,
      this.scrollbarInvisibleWidth = 40.0,
      this.scrollbarWidth = 4.0,
      this.scrollbarActiveWidth = 8.0,
      this.enableJumpScroll = false,
      this.showTouchArea = false,
      this.scrollbarHideAfterDuration = const Duration(milliseconds: 1500),
      this.scrollbarColor = Colors.white,
      required this.child,
      required this.controller});

  final Widget child;
  final double scrollbarHeight;
  final double scrollbarWidth;
  final double scrollbarActiveWidth;
  final double scrollbarInvisibleWidth;
  final double scrollbarTopMargin;
  final double scrollbarBottomMargin;
  final Duration scrollbarHideAfterDuration;
  final ScrollController controller;
  final bool enableJumpScroll;
  final bool showTouchArea;
  final Color scrollbarColor;

  @override
  DraggableScrollbarState createState() => DraggableScrollbarState();
}

class DraggableScrollbarState extends State<DraggableScrollbar> {
  // this counts offset for scroll thumb for Vertical axis
  double _barOffsetTop = 0.0;
  double _barOffsetBottom = 0.0;
  // this counts offset for list in Vertical axis
  double _viewOffset = 0.0;
  // track when scrollbar is dragged
  bool _isDragInProcess = false;
  bool _visible = false;
  bool _invisibleTimerQueued = false;

  bool hideAfterDuration = true;

  @override
  void initState() {
    super.initState();
    _barOffsetTop = 0.0;
    _barOffsetBottom = 0.0;
    _viewOffset = 0.0;
    _isDragInProcess = false;
    _invisibleTimerQueued = false;
    hideAfterDuration = widget.scrollbarHideAfterDuration != Duration.zero;
    _visible = !hideAfterDuration;
  }

  // if list takes 300.0 pixels of height on screen and scrollthumb height is 40.0
  // then max bar offset is 260.0
  double get barMaxScrollExtent =>
      (context.size!.height - (widget.scrollbarHeight + widget.scrollbarBottomMargin)).abs();
  double get barMinScrollExtent => widget.scrollbarTopMargin;

  // this is usually length (in pixels) of list
  // if list has 1000 items of 100.0 pixels each, maxScrollExtent is 100,000.0 pixels
  double get viewMaxScrollExtent => widget.controller.position.maxScrollExtent;
  // this is usually 0.0
  double get viewMinScrollExtent => widget.controller.position.minScrollExtent;
  // double _previousMaxScrollExtent = 0.0;

  double getScrollViewDelta(
    double barDelta,
    double barMaxScrollExtent,
    double viewMaxScrollExtent,
  ) {
    return barDelta * viewMaxScrollExtent / barMaxScrollExtent;
  }

  double getBarDelta(
    double scrollViewDelta,
    double barMaxScrollExtent,
    double viewMaxScrollExtent,
  ) {
    // proportion
    return scrollViewDelta * barMaxScrollExtent / viewMaxScrollExtent;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details, GlobalKey scrollbarKey) {
    if (!_isDragInProcess) {
      return;
    }

    final RenderBox? scrollbarBox = scrollbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (scrollbarBox == null) {
      return;
    }
    final Offset touchPosition = details.globalPosition;
    final Offset scrollbarPosition = scrollbarBox.localToGlobal(Offset.zero);

    // // don't update past the bounds of the list:
    // if (touchPosition.dy < (scrollbarPosition.dy + (widget.scrollbarHeight / 2) + widget.scrollbarTopMargin)) {
    //   // return;
    //   touchPositionY = scrollbarPosition.dy + (widget.scrollbarHeight / 2) + widget.scrollbarTopMargin;
    //   touchDeltaY = 0.0;
    //   _viewOffset = viewMinScrollExtent;
    //   widget.controller.jumpTo(_viewOffset);
    //   // return;
    // }
    // if (touchPosition.dy > ((scrollbarPosition.dy + viewMaxScrollExtent) - (widget.scrollbarHeight / 2))) {
    //   // return;
    //   // touchPositionY = scrollbarPosition.dy + (widget.scrollbarHeight / 2) + widget.scrollbarTopMargin;
    //   touchDeltaY = 0.0;
    //   _viewOffset = viewMaxScrollExtent;
    //   widget.controller.jumpTo(_viewOffset);
    //   // return;
    // }

    setState(() {
      // _barOffsetTop += details.delta.dy;
      final double prevOffset = _barOffsetTop;
      final double moveToHeight = (touchPosition.dy - scrollbarPosition.dy) - (widget.scrollbarHeight / 2);
      _barOffsetTop = (touchPosition.dy - scrollbarPosition.dy) - (widget.scrollbarHeight / 2);

      if (_barOffsetTop < barMinScrollExtent) {
        _barOffsetTop = barMinScrollExtent;
      }
      if (_barOffsetTop > barMaxScrollExtent) {
        _barOffsetTop = barMaxScrollExtent;
      }

      _barOffsetBottom = barMaxScrollExtent - _barOffsetTop;
      if (_barOffsetBottom < 0) {
        _barOffsetBottom = 0;
        throw Exception("_barOffsetBottom < 0");
      }
      if (_barOffsetTop < 0) {
        _barOffsetTop = 0;
        throw Exception("_barOffsetTop < 0");
      }

      // amount to move as scrollViewDelta * (barHeight / viewHeight)
      // double viewDelta = getScrollViewDelta(touchDeltaY, barMaxScrollExtent, viewMaxScrollExtent);
      final double viewDelta = getScrollViewDelta(moveToHeight - prevOffset, barMaxScrollExtent, viewMaxScrollExtent);

      _viewOffset = widget.controller.position.pixels + viewDelta;
      if (_viewOffset < viewMinScrollExtent) {
        _viewOffset = viewMinScrollExtent;
      }
      if (_viewOffset > viewMaxScrollExtent) {
        _viewOffset = viewMaxScrollExtent;
      }
      widget.controller.jumpTo(_viewOffset);
    });
  }

  void _onVerticalDragStart(DragStartDetails details, GlobalKey scrollbarKey) {
    bool shouldStartDrag = true;
    final RenderBox? scrollbarBox = scrollbarKey.currentContext?.findRenderObject() as RenderBox?;
    if (scrollbarBox == null) return;
    final Offset touchPosition = details.globalPosition;
    final Offset scrollbarPosition = scrollbarBox.localToGlobal(Offset.zero);
    final double globalTopOfScrollbar = scrollbarPosition.dy + _barOffsetTop;
    final double globalBottomOfScrollbar = globalTopOfScrollbar + widget.scrollbarHeight;

    // touch is outside of scrollbar
    if (touchPosition.dy < globalTopOfScrollbar || touchPosition.dy > globalBottomOfScrollbar) {
      shouldStartDrag = false;
    }

    final double prevOffset = _barOffsetTop;
    final double moveTo = (touchPosition.dy - scrollbarPosition.dy) - (widget.scrollbarHeight / 2);
    if (widget.enableJumpScroll) {
      final double viewDelta = getScrollViewDelta(moveTo - prevOffset, barMaxScrollExtent, viewMaxScrollExtent);
      _viewOffset = widget.controller.position.pixels + viewDelta;
      if (_viewOffset < viewMinScrollExtent) {
        _viewOffset = viewMinScrollExtent;
      }
      if (_viewOffset > viewMaxScrollExtent) {
        _viewOffset = viewMaxScrollExtent;
      }
      widget.controller.jumpTo(_viewOffset);
    }

    if (_barOffsetBottom < 0) {
      _barOffsetBottom = 0;
    } else if (_barOffsetTop < 0) {
      _barOffsetTop = 0;
    }

    if (shouldStartDrag || widget.enableJumpScroll) {
      sl.get<HapticUtil>().success();
      setState(() {
        _barOffsetTop = (touchPosition.dy - scrollbarPosition.dy) - (widget.scrollbarHeight / 2);
        _isDragInProcess = true;
      });
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (!_isDragInProcess) {
      return;
    }
    setState(() {
      _isDragInProcess = false;
    });
  }

  void hideScrollbar() {
    if (mounted) {
      setState(() {
        _visible = false;
        _invisibleTimerQueued = false;
      });
    }
  }

  // this function process events when scroll controller changes it's position
  // by scrollController.jumpTo or scrollController.animateTo functions.
  // It can be when user scrolls, drags scrollbar (see line 139)
  // or any other manipulation with scrollController outside this widget
  void changePosition(ScrollNotification notification) {
    setState(() {
      _visible = true;
    });
    // set a timer to hide the scrollbar after some time:
    if (!_invisibleTimerQueued && hideAfterDuration) {
      setState(() {
        _invisibleTimerQueued = true;
        Timer(widget.scrollbarHideAfterDuration, hideScrollbar);
      });
    }

    // if notification was fired when user drags we don't need to update scrollThumb position
    if (_isDragInProcess) {
      return;
    }

    setState(() {
      if (notification is ScrollUpdateNotification) {
        _viewOffset += notification.scrollDelta!;
        // lines removed for bounce scroll physics:
        // if (_viewOffset < viewMinScrollExtent) {
        //   _viewOffset = viewMinScrollExtent;
        // }
        // if (_viewOffset > viewMaxScrollExtent) {
        //   _viewOffset = viewMaxScrollExtent;
        // }

        // if (_previousMaxScrollExtent != viewMaxScrollExtent) {
        //   double diff = viewMaxScrollExtent - _previousMaxScrollExtent;
        //   diff = diff * (barMaxScrollExtent / viewMaxScrollExtent);
        //   _barOffsetTop -= diff;
        // }
        // _previousMaxScrollExtent = viewMaxScrollExtent;

        if (_viewOffset < viewMinScrollExtent || _viewOffset > viewMaxScrollExtent) {
          // don't update the bar offset:
          return;
        }

        _barOffsetTop += getBarDelta(
          notification.scrollDelta!,
          barMaxScrollExtent,
          viewMaxScrollExtent,
        );

        if (_barOffsetTop < barMinScrollExtent) {
          _barOffsetTop = barMinScrollExtent;
        }
        if (_barOffsetTop > barMaxScrollExtent) {
          _barOffsetTop = barMaxScrollExtent;
        }
        _barOffsetBottom = barMaxScrollExtent - _barOffsetTop;
        if (_barOffsetBottom < 0) {
          _barOffsetBottom = 0;
        }
        // glue scroll bar to the top on overscroll:
      } else if (notification is OverscrollNotification) {
        if (_barOffsetTop > barMinScrollExtent && notification.overscroll < 0) {
          setState(() {
            _barOffsetTop = barMinScrollExtent;
          });
        }
      }
      /*else if (notification is OverscrollNotification) {
        var diff = viewMaxScrollExtent - _viewOffset;
        if (diff != 0 && diff < 300) {
          _barOffsetTop = barMaxScrollExtent;
        }
      }*/
      // stick the bar to bottom when overscrolling:
      // final double diff = viewMaxScrollExtent - _viewOffset;
      // if (diff != 0 && diff < 200) {
      //   _barOffsetTop = barMaxScrollExtent;
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey scrollbarKey = GlobalKey();
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification notification) {
        changePosition(notification);
        return true;
      },
      child: CustomStack(
        children: <Widget>[
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragStart: (DragStartDetails details) {
              _onVerticalDragStart(details, scrollbarKey);
            },
            onVerticalDragUpdate: (DragUpdateDetails details) {
              _onVerticalDragUpdate(details, scrollbarKey);
            },
            onVerticalDragEnd: _onVerticalDragEnd,
            child: AnimatedOpacity(
              // If the widget is visible, animate to 0.0 (invisible).
              // If the widget is hidden, animate to 1.0 (fully visible).
              opacity: (_visible || _isDragInProcess) ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                key: scrollbarKey,
                alignment: Alignment.topRight,
                decoration: BoxDecoration(
                  // borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                  // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  color: widget.showTouchArea ? Colors.blue : null,
                ),
                width: widget.scrollbarInvisibleWidth,
                height: widget.scrollbarHeight,
                // padding: EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                margin: EdgeInsets.only(
                    top: _barOffsetTop >= 0 ? _barOffsetTop : 0, bottom: _barOffsetBottom >= 0 ? _barOffsetBottom : 0),
                child: _buildScrollThumb(),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }

  Widget _buildScrollThumb() {
    return Container(
      height: widget.scrollbarHeight,
      width: _isDragInProcess ? widget.scrollbarActiveWidth : widget.scrollbarWidth,
      // color: Colors.blue,
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
        // borderRadius: BorderRadius.all(Radius.circular(10)),
        borderRadius: _isDragInProcess
            ? const BorderRadius.all(Radius.circular(10))
            : const BorderRadius.all(Radius.circular(1.5)),
        color: widget.scrollbarColor,
      ),
    );
  }
}

import 'dart:math' as math;
import 'dart:async';

import 'package:flame_jam_2026/game/dialogue/say.dart';
import 'package:flame_jam_2026/game/dialogue/typewriter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TalkDialog extends StatefulWidget {
  const TalkDialog({
    required this.says,
    super.key,
    this.onFinish,
    this.onChangeTalk,
    this.textBoxMinHeight = 100,
    this.keyboardKeysToNext = const [],
    this.padding,
    this.onClose,
    this.dismissible = false,
    this.talkAlignment = Alignment.bottomCenter,
    this.style,
    this.speed = 50,
    this.autoPop = true,
  });

  static Future<T?> show<T>(
    BuildContext context,
    List<Say> sayList, {
    VoidCallback? onFinish,
    VoidCallback? onClose,
    ValueChanged<int>? onChangeTalk,
    Color? backgroundColor,
    double boxTextHeight = 100,
    List<LogicalKeyboardKey> logicalKeyboardKeysToNext = const [],
    EdgeInsetsGeometry? padding,
    bool dismissible = false,
    bool useSafeArea = true,
    bool useRootNavigator = true,
    Alignment talkAlignment = Alignment.bottomCenter,
    TextStyle? style,
    int speed = 50,
  }) {
    return showDialog<T>(
      barrierDismissible: dismissible,
      barrierColor: backgroundColor,
      context: context,
      useSafeArea: useSafeArea,
      useRootNavigator: useRootNavigator,
      builder: (BuildContext context) {
        return TalkDialog(
          says: sayList,
          onFinish: onFinish,
          onClose: onClose,
          onChangeTalk: onChangeTalk,
          textBoxMinHeight: boxTextHeight,
          keyboardKeysToNext: logicalKeyboardKeysToNext,
          padding: padding,
          dismissible: dismissible,
          talkAlignment: talkAlignment,
          style: style,
          speed: speed,
        );
      },
    );
  }

  final List<Say> says;
  final VoidCallback? onFinish;
  final VoidCallback? onClose;
  final ValueChanged<int>? onChangeTalk;
  final double? textBoxMinHeight;
  final List<LogicalKeyboardKey> keyboardKeysToNext;
  final EdgeInsetsGeometry? padding;
  final bool dismissible;
  final Alignment talkAlignment;
  final TextStyle? style;

  /// in milliseconds
  final int speed;

  /// Whether to call Navigator.pop when dialogue finishes.
  /// Set to false when used as an overlay instead of showDialog.
  final bool autoPop;

  @override
  TalkDialogState createState() => TalkDialogState();
}

class TalkDialogState extends State<TalkDialog> {
  static const Size _designViewportSize = Size(1280, 720);

  final FocusNode _focusNode = FocusNode();
  int currentIndexTalk = 0;
  bool finishedCurrentSay = false;

  final GlobalKey<TypeWriterState> _writerKey = GlobalKey();

  Say get _currentSay => widget.says[currentIndexTalk];

  @override
  void initState() {
    Future.delayed(Duration.zero, _focusNode.requestFocus);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant TalkDialog oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.says.isEmpty) {
      return;
    }

    if (currentIndexTalk >= widget.says.length) {
      currentIndexTalk = widget.says.length - 1;
    }

    if (!identical(oldWidget.says, widget.says)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || widget.says.isEmpty) return;
        _writerKey.currentState?.start(text: _currentSay.text);
      });
    }
  }

  @override
  void dispose() {
    widget.onClose?.call();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSay = _currentSay;
    final resolvedPadding = (widget.padding ?? const EdgeInsets.all(10))
        .resolve(Directionality.of(context));

    return Material(
      type: MaterialType.transparency,
      child: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: (raw) {
          if (widget.keyboardKeysToNext.isEmpty && raw is KeyDownEvent) {
            // Prevent volume buttons from triggering the next dialog
            if (raw.logicalKey != LogicalKeyboardKey.audioVolumeUp &&
                raw.logicalKey != LogicalKeyboardKey.audioVolumeDown) {
              _nextOrFinish();
            }
          } else if (widget.keyboardKeysToNext.contains(raw.logicalKey) &&
              raw is KeyDownEvent) {
            _nextOrFinish();
          }
        },
        child: GestureDetector(
          onTap: _nextOrFinish,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final viewportSize = _gameViewportFor(constraints.biggest);
              final scaleX = viewportSize.width / _designViewportSize.width;
              final scaleY = viewportSize.height / _designViewportSize.height;
              final scale = math.min(scaleX, scaleY);
              final contentScale = scale.clamp(0.64, 1.0);
              final normalizedScale = ((scale - 0.5) / 0.5).clamp(0.0, 1.0);
              final scaledPadding = _scaleInsets(
                resolvedPadding,
                scaleX,
                scaleY,
              );
              final availableContentWidth = math.max(
                0.0,
                viewportSize.width - scaledPadding.horizontal,
              );
              final bubblePadding = _scaleInsets(
                (currentSay.padding ?? const EdgeInsets.all(10)).resolve(
                  Directionality.of(context),
                ),
                contentScale,
                contentScale,
              );
              final textStyle = _scaleTextStyle(
                widget.style,
                _lerpDouble(0.56, 1.0, normalizedScale),
              );
              final portraitBaseSize =
                  currentSay.personSize ?? const Size(184, 184);
              final portraitWidth =
                  (portraitBaseSize.width * math.max(scale, 0.68)).clamp(
                    88.0,
                    168.0,
                  );
              final portraitHeight =
                  (portraitBaseSize.height * math.max(scale, 0.68)).clamp(
                    88.0,
                    168.0,
                  );
              final portraitGap =
                  ((currentSay.personOutsideOffset ?? 14.0) * contentScale)
                      .clamp(4.0, 14.0);
              final portraitBaseTopOffset =
                  currentSay.personTopOffset ??
                  (-(portraitBaseSize.height * 0.3));
              final portraitSlotWidth = currentSay.person == null
                  ? 0.0
                  : portraitWidth + portraitGap;
              final dialogWidthFactor = _lerpDouble(
                0.76,
                0.58,
                normalizedScale,
              );
              final minBubbleWidth = currentSay.person == null ? 280.0 : 220.0;
              final availableBubbleWidth = math.max(
                0.0,
                availableContentWidth - portraitSlotWidth,
              );
              final bubbleWidth = math.min(
                availableBubbleWidth,
                math.max(
                  viewportSize.width * dialogWidthFactor,
                  minBubbleWidth,
                ),
              );
              final portraitTopOffset = portraitBaseTopOffset * contentScale;
              final minTextHeight = widget.textBoxMinHeight == null
                  ? null
                  : (widget.textBoxMinHeight! * contentScale).clamp(
                      80.0,
                      widget.textBoxMinHeight!,
                    );

              return Container(
                color: Colors.transparent,
                alignment: Alignment.center,
                child: SizedBox(
                  width: viewportSize.width,
                  height: viewportSize.height,
                  child: Padding(
                    padding: scaledPadding,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: widget.talkAlignment,
                      children: [
                        Align(
                          alignment: _getAlign(currentSay.personSayDirection),
                          child:
                              currentSay.background ?? const SizedBox.shrink(),
                        ),
                        Align(
                          alignment: widget.talkAlignment,
                          child: SizedBox(
                            width: bubbleWidth + portraitSlotWidth,
                            child: _buildTalkCard(
                              currentSay,
                              bubbleWidth: bubbleWidth,
                              bubblePadding: bubblePadding,
                              textStyle: textStyle,
                              minTextHeight: minTextHeight,
                              portraitWidth: portraitWidth,
                              portraitHeight: portraitHeight,
                              portraitGap: portraitGap,
                              portraitTopOffset: portraitTopOffset,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _finishCurrentSay() {
    _writerKey.currentState?.finishTyping();
    finishedCurrentSay = true;
  }

  void _nextSay() {
    currentIndexTalk++;
    if (currentIndexTalk < widget.says.length) {
      setState(() {
        finishedCurrentSay = false;
      });
      _writerKey.currentState?.start(text: _currentSay.text);
      widget.onChangeTalk?.call(currentIndexTalk);
    } else {
      widget.onFinish?.call();
      if (widget.autoPop) {
        Navigator.pop(context);
      }
    }
  }

  void _nextOrFinish() {
    if (finishedCurrentSay) {
      _nextSay();
    } else {
      _finishCurrentSay();
    }
  }

  Widget _buildTalkCard(
    Say currentSay, {
    required double bubbleWidth,
    required EdgeInsetsGeometry bubblePadding,
    required TextStyle textStyle,
    required double? minTextHeight,
    required double portraitWidth,
    required double portraitHeight,
    required double portraitGap,
    required double portraitTopOffset,
  }) {
    final hasPortrait = currentSay.person != null;
    final bubble = SizedBox(
      width: bubbleWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          currentSay.header ?? const SizedBox.shrink(),
          Container(
            width: double.maxFinite,
            padding: bubblePadding,
            margin: currentSay.margin,
            constraints: minTextHeight != null
                ? BoxConstraints(minHeight: minTextHeight)
                : null,
            decoration:
                currentSay.boxDecoration ??
                BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TypeWriter(
                key: _writerKey,
                text: currentSay.text,
                speed: widget.speed,
                style: textStyle,
                onFinish: () {
                  finishedCurrentSay = true;
                },
              ),
            ),
          ),
          currentSay.bottom ?? const SizedBox.shrink(),
        ],
      ),
    );

    final portrait = hasPortrait
        ? Transform.translate(
            offset: Offset(0, portraitTopOffset),
            child: SizedBox(
              width: portraitWidth,
              height: portraitHeight,
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
                child: currentSay.person,
              ),
            ),
          )
        : null;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (currentSay.personSayDirection == PersonSayDirection.LEFT &&
            portrait != null) ...[
          portrait,
          SizedBox(width: portraitGap),
        ],
        bubble,
        if (currentSay.personSayDirection == PersonSayDirection.RIGHT &&
            portrait != null) ...[
          SizedBox(width: portraitGap),
          portrait,
        ],
      ],
    );
  }

  Size _gameViewportFor(Size available) {
    final designAspect = _designViewportSize.width / _designViewportSize.height;
    final availableAspect = available.width / available.height;

    if (availableAspect > designAspect) {
      final height = available.height;
      return Size(height * designAspect, height);
    }

    final width = available.width;
    return Size(width, width / designAspect);
  }

  EdgeInsets _scaleInsets(EdgeInsets insets, double scaleX, double scaleY) {
    return EdgeInsets.fromLTRB(
      insets.left * scaleX,
      insets.top * scaleY,
      insets.right * scaleX,
      insets.bottom * scaleY,
    );
  }

  TextStyle _scaleTextStyle(TextStyle? style, double scale) {
    final baseStyle =
        style ?? const TextStyle(color: Colors.white, fontSize: 16);
    final baseFontSize = baseStyle.fontSize ?? 16;

    return baseStyle.copyWith(fontSize: baseFontSize * scale);
  }

  double _lerpDouble(double a, double b, double t) {
    return a + ((b - a) * t);
  }

  Alignment _getAlign(PersonSayDirection personDirection) {
    return personDirection == PersonSayDirection.LEFT
        ? Alignment.bottomLeft
        : Alignment.bottomRight;
  }
}

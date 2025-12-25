import 'package:nazara/common_libs.dart';

/// The core button that drives all other buttons.
class AppBtn extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  AppBtn({
    super.key,
    required this.onPressed,
    this.enableFeedback = true,
    this.pressEffect = true,
    this.hoverEffect = true,
    this.child,
    this.padding,
    this.expand = false,
    this.isSecondary = false,
    this.circular = false,
    this.minimumSize,
    this.bgColor,
    this.border,
    this.focusNode,
    this.onFocusChanged,
  }) : _builder = null;

  // ignore: prefer_const_constructors_in_immutables
  AppBtn.basic({
    super.key,
    required this.onPressed,

    this.enableFeedback = true,
    this.pressEffect = true,
    this.hoverEffect = true,
    this.child,
    this.padding = EdgeInsets.zero,
    this.isSecondary = false,
    this.circular = false,
    this.minimumSize,
    this.focusNode,
    this.onFocusChanged,
  }) : expand = false,
       bgColor = Colors.transparent,
       border = null,
       _builder = null;

  // interaction:
  final VoidCallback? onPressed;
  final bool enableFeedback;
  final FocusNode? focusNode;
  final void Function(bool hasFocus)? onFocusChanged;

  // content:
  late final Widget? child;
  late final WidgetBuilder? _builder;

  // layout:
  final EdgeInsets? padding;
  final bool expand;
  final bool circular;
  final Size? minimumSize;

  // style:
  final bool isSecondary;
  final BorderSide? border;
  final Color? bgColor;
  final bool pressEffect;
  final bool hoverEffect;

  @override
  Widget build(BuildContext context) {
    Color defaultColor = isSecondary ? Colors.white : Colors.grey;
    Color textColor = isSecondary ? Colors.black : Colors.white;
    BorderSide side = border ?? BorderSide.none;

    Widget content = _builder?.call(context) ?? child ?? SizedBox.shrink();
    if (expand) content = Center(child: content);

    OutlinedBorder shape = circular
        ? CircleBorder(side: side)
        : RoundedRectangleBorder(
            side: side,
            borderRadius: BorderRadius.circular(12),
          );

    ButtonStyle style = ButtonStyle(
      minimumSize: ButtonStyleButton.allOrNull<Size>(minimumSize ?? Size.zero),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      splashFactory: NoSplash.splashFactory,
      backgroundColor: ButtonStyleButton.allOrNull<Color>(
        bgColor ?? defaultColor,
      ),
      overlayColor: ButtonStyleButton.allOrNull<Color>(Colors.transparent),
      shape: ButtonStyleButton.allOrNull<OutlinedBorder>(shape),
      padding: ButtonStyleButton.allOrNull<EdgeInsetsGeometry>(
        padding ?? EdgeInsets.all(24),
      ),

      enableFeedback: enableFeedback,
    );

    Widget button = _CustomFocusBuilder(
      focusNode: focusNode,
      onFocusChanged: onFocusChanged,
      builder: (context, focus) => Stack(
        children: [
          AnimatedOpacity(
            duration: 200.ms,
            opacity: onPressed == null ? 0.5 : 1.0,
            child: TextButton(
              onPressed: onPressed,
              style: style,
              focusNode: focus,
              child: DefaultTextStyle(
                style: DefaultTextStyle.of(
                  context,
                ).style.copyWith(color: textColor),
                child: content,
              ),
            ),
          ),
          if (focus.hasFocus)
            Positioned.fill(
              child: AnimatedContainer(
                duration: 200.ms,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Color(0xff1ED760), width: 4),
                ),
              ),
            ),
        ],
      ),
    );

    // add press effect:
    if (pressEffect && onPressed != null) button = _ButtonPressEffect(button);

    return button;
  }
}

/// //////////////////////////////////////////////////
/// _ButtonDecorator
/// Add a transparency-based press effect to buttons.
/// //////////////////////////////////////////////////
class _ButtonPressEffect extends StatefulWidget {
  const _ButtonPressEffect(this.child);
  final Widget child;

  @override
  State<_ButtonPressEffect> createState() => _ButtonPressEffectState();
}

class _ButtonPressEffectState extends State<_ButtonPressEffect> {
  bool _isDown = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      excludeFromSemantics: true,
      onTapDown: (_) => setState(() => _isDown = true),
      onTapUp: (_) => setState(
        () => _isDown = false,
      ), 
      onTapCancel: () => setState(() => _isDown = false),
      behavior: HitTestBehavior.translucent,
      child: AnimatedOpacity(
        duration: 200.ms,
        opacity: _isDown ? 0.7 : 1,
        child: ExcludeSemantics(child: widget.child),
      ),
    );
  }
}

class _CustomFocusBuilder extends StatefulWidget {
  const _CustomFocusBuilder({
    required this.builder,
    this.focusNode,
    this.onFocusChanged,
  });
  final Widget Function(BuildContext context, FocusNode focus) builder;
  final void Function(bool hasFocus)? onFocusChanged;
  final FocusNode? focusNode;
  @override
  State<_CustomFocusBuilder> createState() => _CustomFocusBuilderState();
}

class _CustomFocusBuilderState extends State<_CustomFocusBuilder> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChanged);
    super.initState();
  }

  void _handleFocusChanged() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder.call(context, _focusNode);
  }
}

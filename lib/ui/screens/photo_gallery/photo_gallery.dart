import 'dart:async';
import 'package:nazara/common_libs.dart';
import 'package:nazara/logic/common/animate_utils.dart';
part 'widgets/_animated_cutout_overlay.dart';

class NazaraGallery extends StatefulWidget {
  const NazaraGallery({super.key, this.imageSize});
  final Size? imageSize;

  @override
  State<NazaraGallery> createState() => _NazaraGalleryState();
}

class _NazaraGalleryState extends State<NazaraGallery> {
  static const int _gridSize = 5; // 5 columns
  static const int _imgCount = 25; // 25 images total (5 rows x 5 columns)
  // Index starts at the first image
  int _index = 0;
  Offset _lastSwipeDir = Offset.zero;
  final double _scale = 1;
  bool _skipNextOffsetTween = false;
  late Duration swipeDuration = 600.ms * .4;

  // Generate 25 image paths, repeating the available 13 images (0.jpg through 12.jpg)
  final List<String> _photoAssets = List.generate(25, (i) {
    int imageIndex = i % 24; // Cycle through 0-24
    return 'assets/images/$imageIndex.jpg';
  });

  late final List<FocusNode> _focusNodes = List.generate(
    _imgCount,
    (index) => FocusNode(),
  );

  @override
  void initState() {
    super.initState();
    _focusNodes[_index].requestFocus();
  }

  void _setIndex(int value, {bool skipAnimation = false}) {
    if (value < 0 || value >= _imgCount) return;
    _skipNextOffsetTween = skipAnimation;
    setState(() => _index = value);
    _focusNodes[value].requestFocus();
  }

  /// Determine the required offset to show the current selected index.
  /// index=0 is top-left, and the index=max is bottom-right.
  Offset _calculateCurrentOffset(
    double padding,
    Size size,
    BuildContext context,
  ) {
    Size paddedImageSize = Size(size.width + padding, size.height + padding);
    // Calculate the current image's row and column
    int col = _index % _gridSize;
    int row = (_index / _gridSize).floor();

    // Calculate the number of rows in the grid
    int numRows = (_imgCount / _gridSize).ceil();

    // Create an origin offset that centers the grid
    // For columns: center based on grid width
    // For rows: center based on number of rows
    final originOffset = Offset(
      (_gridSize / 2).floorToDouble() * paddedImageSize.width,
      (numRows / 2).floorToDouble() * paddedImageSize.height,
    );

    // Calculate offset for the selected image
    final indexedOffset = Offset(
      -paddedImageSize.width * col,
      -paddedImageSize.height * row,
    );

    // Combine offsets and adjust for safe area
    return originOffset +
        indexedOffset +
        Offset(0, -context.mq.padding.top / 2);
  }

  /// Converts a swipe direction into a new index
  void _handleSwipe(Offset dir) {
    // Calculate new index, y swipes move by an entire row, x swipes move one index at a time
    int newIndex = _index;
    if (dir.dy != 0) newIndex += _gridSize * (dir.dy > 0 ? -1 : 1);
    if (dir.dx != 0) newIndex += (dir.dx > 0 ? -1 : 1);
    // After calculating new index, exit early if we don't like it...
    if (newIndex < 0 || newIndex > _imgCount - 1) {
      return; // keep the index in range
    }
    if (dir.dx < 0 && newIndex % _gridSize == 0) {
      return; // prevent right-swipe when at right side
    }
    if (dir.dx > 0 && newIndex % _gridSize == _gridSize - 1) {
      return; // prevent left-swipe when at left side
    }
    _lastSwipeDir = dir;
    HapticFeedback.lightImpact();
    _setIndex(newIndex);
  }

  Future<void> _handleImageTapped(int index, bool isSelected) async {
    if (_index != index) {
      _setIndex(index);
    }
  }

  void _handleImageFocusChanged(int index, bool isFocused) {
    if (isFocused) {
      _setIndex(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (_) {
        Size imgSize = context.isLandscape
            ? Size(context.widthPx * .5, context.heightPx * .66)
            : Size(context.widthPx * .66, context.heightPx * .5);
        imgSize = (widget.imageSize ?? imgSize) * _scale;
        // Get transform offset for the current _index
        final double padding = 24;
        var gridOffset = _calculateCurrentOffset(padding, imgSize, context);
        final offsetTweenDuration = _skipNextOffsetTween
            ? Duration.zero
            : swipeDuration;
        final cutoutTweenDuration = _skipNextOffsetTween
            ? Duration.zero
            : swipeDuration * .5;
        return _AnimatedCutoutOverlay(
          animationKey: ValueKey(_index),
          cutoutSize: imgSize,
          swipeDir: _lastSwipeDir,
          duration: cutoutTweenDuration,
          opacity: _scale == 1 ? .7 : .5,
          enabled: true,
          child: SafeArea(
            bottom: false,
            // Place content in overflow box, to allow it to flow outside the parent
            child: OverflowBox(
              maxWidth: _gridSize * imgSize.width + padding * (_gridSize - 1),
              maxHeight:
                  (_imgCount / _gridSize).ceil() * imgSize.height +
                  padding * ((_imgCount / _gridSize).ceil() - 1),
              alignment: Alignment.center,
              // Detect swipes in order to change index
              child: EightWaySwipeDetector(
                onSwipe: _handleSwipe,
                threshold: 30,
                // A tween animation builder moves from image to image based on current offset
                child: TweenAnimationBuilder<Offset>(
                  tween: Tween(begin: gridOffset, end: gridOffset),
                  duration: offsetTweenDuration,
                  curve: Curves.easeOut,
                  builder: (_, value, child) =>
                      Transform.translate(offset: value, child: child),
                  child: FocusTraversalGroup(
                    //policy: OrderedTraversalPolicy(),
                    child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: _gridSize,
                      childAspectRatio: imgSize.aspectRatio,
                      mainAxisSpacing: padding,
                      crossAxisSpacing: padding,
                      children: List.generate(
                        _imgCount,
                        (i) => _buildImage(i, swipeDuration, imgSize),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage(int index, Duration swipeDuration, Size imgSize) {
    return FocusTraversalOrder(
      order: NumericFocusOrder(index.toDouble()),
      child: Builder(
        builder: (_) {
          bool isSelected = index == _index;
          final imgAsset = _photoAssets[index];

          final photoWidget = TweenAnimationBuilder<double>(
            duration: 600.ms,
            curve: Curves.easeOut,
            tween: Tween(begin: 1, end: isSelected ? 1.15 : 1),
            builder: (_, value, child) =>
                Transform.scale(scale: value, child: child),
            child: Image.asset(
              imgAsset,
              fit: BoxFit.cover,
            ).maybeAnimate().fade(),
          );

          return AppBtn.basic(
            focusNode: _focusNodes[index],
            onFocusChanged: (isFocused) =>
                _handleImageFocusChanged(index, isFocused),
            onPressed: () => _handleImageTapped(index, isSelected),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: imgSize.width,
                height: imgSize.height,
                child: photoWidget,
              ),
            ),
          );
        },
      ),
    );
  }
}

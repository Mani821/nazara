import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nazara/ui/screens/photo_gallery/photo_gallery.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  static const double _imageSize = 250;
  static List<_PageData> pageData = [];

  late final ValueNotifier<int> _currentPage = ValueNotifier(0)
    ..addListener(() => setState(() {}));

  late final PageController _pageController = PageController()
    ..addListener(_handlePageChanged);

  void _handlePageChanged() {
    int newPage = _pageController.page?.round() ?? 0;
    _currentPage.value = newPage;
  }

  @override
  void dispose() {
    _pageController.dispose();
    _currentPage.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    pageData = [
      _PageData(
        "The nation",
        "Shaped by history, belief, and resilience.",
        'badshahi',
        '1',
      ),
      _PageData(
        "Everyday Life",
        "Work, faith, family, and routine shape daily life.",
        'people',
        '3',
      ),
      _PageData(
        "A Shared Identity",
        "Diverse communities come together in unity.",
        'faisal',
        '2',
      ),
    ];

    final List<Widget> pages = pageData.map((e) => _Page(data: e)).toList();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: double.infinity),
                Spacer(),
                Image.asset('assets/icons/star.png', height: 50, width: 50),
                Semantics(
                  header: true,
                  child: Text(
                    'Nazara',
                    style: GoogleFonts.cinzelDecorative(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          offset: Offset(1, 3),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                IgnorePointer(
                  child: SizedBox(
                    height: _imageSize,
                    width: _imageSize,
                    child: ValueListenableBuilder<int>(
                      valueListenable: _currentPage,
                      builder: (_, value, __) {
                        return AnimatedSwitcher(
                          duration: 900.ms,
                          child: KeyedSubtree(
                            key: ValueKey(value),
                            child: _PageImage(data: pageData[value]),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 20),
                IgnorePointer(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 250),
                        margin: EdgeInsets.symmetric(horizontal: 2.0),
                        height: 5.0,
                        width: _currentPage.value == index ? 14.0 : 8.0,
                        decoration: BoxDecoration(
                          color: _currentPage.value == index
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(5.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(1, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
                Spacer(flex: 2),
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 18.0) +
                      EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    'Swipe to continue',
                    style: GoogleFonts.raleway(
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w500,
                    ),
                  ).animate(target: _currentPage.value == 2 ? 1 : 0).fadeOut(),
                ),
              ],
            ),
            PageView(
              controller: _pageController,
              children: pages,
              onPageChanged: (value) {
                HapticFeedback.lightImpact();
                setState(() {
                  _currentPage.value = value;
                });
              },
            ),
            Positioned(
              bottom: 26,
              right: 30,
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    PageRouteBuilder(
                      transitionDuration: const Duration(milliseconds: 600),
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          NazaraGallery(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                    ),
                    (Route<dynamic> route) => false,
                  );
                },
                child: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Color(0xff1ED760),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward, color: Color(0xff0E1B0E)),
                ).animate(target: _currentPage.value == 2 ? 1 : 0).fadeIn(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@immutable
class _PageData {
  const _PageData(this.title, this.desc, this.img, this.mask);

  final String title;
  final String desc;
  final String img;
  final String mask;
}

class _Page extends StatelessWidget {
  const _Page({required this.data});

  final _PageData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Spacer(flex: 4),
          Text(
            data.title,
            style: GoogleFonts.cinzelDecorative(
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            data.desc,
            style: GoogleFonts.raleway(
              color: Colors.grey[300],
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          Spacer(),
        ],
      ),
    );
  }
}

class _PageImage extends StatelessWidget {
  const _PageImage({required this.data});

  final _PageData data;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: Image.asset(
            'assets/images/${data.img}.jpg',
            excludeFromSemantics: true,
            fit: BoxFit.cover,
            alignment: Alignment.centerRight,
          ),
        ),
        Positioned.fill(
          child: Image.asset(
            'assets/masks/intro-mask-${data.mask}.png',
            excludeFromSemantics: true,
            fit: BoxFit.fill,
          ),
        ),
      ],
    );
  }
}

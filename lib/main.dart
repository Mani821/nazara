import 'package:nazara/ui/intro/intro_page.dart';
import 'package:nazara/common_libs.dart';

void main() {
  runApp(const Nazara());
}

class Nazara extends StatelessWidget {
  const Nazara({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nazara',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: Color(0xff1E1B18)),
      home: const IntroPage(),
    );
  }
}


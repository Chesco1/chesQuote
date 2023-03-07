import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quotes/notifiers/animation_notifier.dart';
import 'package:quotes/notifiers/quote_notifier.dart';
import 'package:quotes/views/quote_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.openSansTextTheme(),
      ),
      home: MultiProvider(
        providers: [
          ChangeNotifierProvider<AnimationNotifier>(
            create: (_) => AnimationNotifier(),
          ),
          ChangeNotifierProvider<QuoteNotifier>(
            create: (_) => QuoteNotifier(),
          ),
        ],
        child: const QuotePage(),
      ),
    );
  }
}

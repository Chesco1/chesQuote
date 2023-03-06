import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quotes/notifiers/quote_notifier.dart';

class QuoteWidget extends StatefulWidget {
  const QuoteWidget({super.key});

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  late final QuoteNotifier quoteProvider;

  @override
  void initState() {
    super.initState();
    quoteProvider = context.read<QuoteNotifier>();
    quoteProvider.initializeQuotes();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<QuoteNotifier>();
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxWidth * 0.1,
            ),
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/quote_background.png"),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 90),
                const AppTitle(
                  title: "ChesQuotes",
                  fontSize: 42,
                ),
                const SizedBox(height: 30),
                QuoteContainer(
                  quoteText: quoteProvider.currentQuote.text,
                  quoteAuthor: quoteProvider.currentQuote.author,
                  height: 170,
                ),
                const SizedBox(height: 30),
                ShareAndLikeRow(quoteProvider: quoteProvider),
                const SizedBox(height: 45),
                PrimaryButton(
                  'Next Genius Quote',
                  size: Size(
                    constraints.maxHeight * 0.31,
                    constraints.maxHeight * 0.08,
                  ),
                  onPressed: () {
                    quoteProvider.getNextQuote();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////

class AppTitle extends StatelessWidget {
  final String title;
  final double fontSize;
  const AppTitle({super.key, required this.title, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.playfairDisplay(fontSize: fontSize),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////

class QuoteContainer extends StatelessWidget {
  final String quoteText;
  final String quoteAuthor;
  final double? height;
  const QuoteContainer({
    super.key,
    required this.quoteText,
    required this.quoteAuthor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AutoSizeText(
            maxLines: 4,
            quoteText,
            style: GoogleFonts.playfairDisplay(fontSize: 20.0),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Text(
              "- $quoteAuthor",
              style: const TextStyle(
                fontSize: 15.0,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////

class ShareAndLikeRow extends StatelessWidget {
  final QuoteNotifier quoteProvider;
  const ShareAndLikeRow({super.key, required this.quoteProvider});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            quoteProvider.shareQuote(quoteProvider.currentQuote);
          },
          child: Image.asset(
            'assets/images/share.png',
            height: 32,
            width: 32,
          ),
        ),
        const SizedBox(width: 50),
        GestureDetector(
          onTap: () {
            quoteProvider.toggleLike(quoteProvider.currentQuote);
          },
          child: Image.asset(
            quoteProvider.isQuoteLiked(quoteProvider.currentQuote)
                ? 'assets/images/heart_filled.png'
                : 'assets/images/heart_empty.png',
            height: 32,
            width: 32,
          ),
        ),
      ],
    );
  }
}

////////////////////////////////////////////////////////////////////////////////

class PrimaryButton extends StatelessWidget {
  final Size size;
  final String text;
  final void Function()? onPressed;

  const PrimaryButton(
    this.text, {
    super.key,
    required this.onPressed,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 4),
            blurRadius: 2.0,
            spreadRadius: 0,
            color: Colors.black54,
          ),
        ],
        borderRadius: BorderRadius.circular(100.0),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF585858),
            Color(0xFF161616),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          fixedSize: size,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: GoogleFonts.openSans(),
        ),
      ),
    );
  }
}

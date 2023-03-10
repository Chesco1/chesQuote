import 'dart:collection';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:quotes/models/quote.dart';
import 'package:quotes/notifiers/animation_notifier.dart';
import 'package:quotes/notifiers/quote_notifier.dart';

class QuoteWidget extends StatefulWidget {
  const QuoteWidget({super.key});

  @override
  State<QuoteWidget> createState() => _QuoteWidgetState();
}

class _QuoteWidgetState extends State<QuoteWidget> {
  late final QuoteNotifier quoteNotifier;
  late final AnimationNotifier animationNotifier;

  Future<void> initilizePage() async {
    await quoteNotifier.initializeQuotes();
    await animationNotifier.showElements();
  }

  @override
  void initState() {
    super.initState();
    quoteNotifier = context.read<QuoteNotifier>();
    animationNotifier = context.read<AnimationNotifier>();
    initilizePage();
  }

  @override
  Widget build(BuildContext context) {
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
                  animationNotifier: animationNotifier,
                  height: 170,
                ),
                const SizedBox(height: 30),
                ShareAndLikeRow(
                  quoteNotifier: quoteNotifier,
                  animationNotifier: animationNotifier,
                ),
                const SizedBox(height: 45),
                PrimaryButton(
                  text: 'Generate Next Quote',
                  animationNotifier: animationNotifier,
                  size: Size(
                    constraints.maxHeight * 0.29,
                    constraints.maxHeight * 0.077,
                  ),
                  onPressed: () async {
                    await animationNotifier.hideElements();
                    await quoteNotifier.getNextQuote();
                    await animationNotifier.showElements();
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
  final AnimationNotifier animationNotifier;
  final double? height;

  const QuoteContainer({
    super.key,
    required this.animationNotifier,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    {
      final currentQuote = context.select<QuoteNotifier, Quote>(
          (quoteNotifier) => quoteNotifier.currentQuote);
      return SizedBox(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            AnimatedOpacity(
              opacity: context.select<AnimationNotifier, bool>(
                      (notifier) => notifier.showQuoteText())
                  ? 1
                  : 0,
              duration: animationNotifier.fadeDuration,
              child: AutoSizeText(
                currentQuote.text,
                maxLines: 4,
                style: GoogleFonts.playfairDisplay(fontSize: 20.0),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: AnimatedOpacity(
                opacity: context.select<AnimationNotifier, bool>(
                        (notifier) => notifier.showQuoteAuthor())
                    ? 1
                    : 0,
                duration: animationNotifier.fadeDuration,
                child: Text(
                  "- ${currentQuote.author}",
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
  }
}

////////////////////////////////////////////////////////////////////////////////

class ShareAndLikeRow extends StatelessWidget {
  final QuoteNotifier quoteNotifier;
  final AnimationNotifier animationNotifier;
  const ShareAndLikeRow({
    super.key,
    required this.quoteNotifier,
    required this.animationNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: context.select<AnimationNotifier, bool>(
        (animationNotifier) => animationNotifier.shouldIgnoreButtonClicks(),
      ),
      child: AnimatedOpacity(
        opacity: context.select<AnimationNotifier, bool>(
          (animationNotifier) => animationNotifier.showShareAndLikeRow(),
        )
            ? 1
            : 0,
        duration: animationNotifier.fadeDuration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                animationNotifier.setButtonClickability(false);
                try {
                  await quoteNotifier.shareQuote(quoteNotifier.currentQuote);
                  //making sure there can't be multiple stacked share windows
                  await Future.delayed(const Duration(milliseconds: 300));
                } finally {
                  animationNotifier.setButtonClickability(true);
                }
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
                quoteNotifier.toggleLike(quoteNotifier.currentQuote);
              },
              child: Image.asset(
                context.select<QuoteNotifier, bool>(
                  (notifier) => notifier.isQuoteLiked(
                    quoteNotifier.currentQuote,
                  ),
                )
                    ? 'assets/images/heart_filled.png'
                    : 'assets/images/heart_empty.png',
                height: 32,
                width: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

////////////////////////////////////////////////////////////////////////////////

class PrimaryButton extends StatelessWidget {
  final AnimationNotifier animationNotifier;
  final Size size;
  final String text;
  final void Function()? onPressed;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.size,
    required this.animationNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: context.select<AnimationNotifier, bool>(
        (notifier) => notifier.shouldIgnoreButtonClicks(),
      ),
      child: AnimatedOpacity(
        opacity: context.select<AnimationNotifier, bool>(
          (notifier) => notifier.showShareAndLikeRow(),
        )
            ? 1
            : 0,
        duration: animationNotifier.fadeDuration,
        child: Container(
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
        ),
      ),
    );
  }
}

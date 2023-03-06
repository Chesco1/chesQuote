import 'dart:math';
import 'package:flutter/material.dart';
import 'package:quotes/views/quote_widget.dart';

class QuotePage extends StatelessWidget {
  static const double minHeight = 600;
  static const double maxWidth = 500;
  const QuotePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            height: max(minHeight, constraints.maxHeight),
            alignment: Alignment.center,
            color: Colors.grey,
            child: Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width >= maxWidth
                  ? maxWidth
                  : null,
              child: const QuoteWidget(),
            ),
          ),
        );
      },
    );
  }
}

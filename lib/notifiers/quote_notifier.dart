import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quotes/models/quote.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';

class QuoteNotifier extends ChangeNotifier {
  final _quotesPerPage = 10;
  List<Quote> _backupQuoteList = [];
  List<Quote> _quoteList = [];
  final List<Quote> _likedQuotes = [];
  int _currentQuoteIndex = 0;
  Quote currentQuote = Quote(text: "", author: "");
  bool _didLastFetchSucceed = false;

  void toggleLike(Quote quote) {
    if (isQuoteLiked(quote)) {
      _likedQuotes.removeWhere((element) =>
          element.author == quote.author && element.text == quote.text);
    } else {
      _likedQuotes.add(quote);
    }
    notifyListeners();
  }

  bool isQuoteLiked(Quote quote) {
    for (Quote q in _likedQuotes) {
      if (q.author == quote.author && q.text == quote.text) {
        return true;
      }
    }
    return false;
  }

  /// This function formats the quote and allows it to be shared.
  /// I deliberately left out mentioning the auther of the quote,
  /// because I thought this format was more funny.
  void shareQuote(Quote quote) {
    Share.share(
      quote.text,
      subject: "Have you considered this?",
    );
  }

  ///This function returns true if the last fetch attempt failed
  ///or if all of the quotes in [_quoteList] have been shown
  bool _shouldFetchQuotes() {
    if (!_didLastFetchSucceed || _currentQuoteIndex >= _quoteList.length - 1) {
      return true;
    }
    return false;
  }

  ///This function will try to fetch [_quotesPerPage] amount of quotes from
  ///the API and store them in [_quoteList], overwriting its previous content.
  ///If in any way fetching is unsuccesful the function will throw.
  Future<void> _fetchQuotes() async {
    Random rng = Random();
    int randomPage = rng.nextInt((2042 / _quotesPerPage).floor()) + 1;
    final url = Uri.parse(
      'https://api.quotable.io/quotes?limit=$_quotesPerPage&page=$randomPage&maxLength=130',
    );

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 3));
      // check if http request was succesful
      if (response.statusCode == 200) {
        final Map<String, dynamic> quotesJson = json.decode(response.body);
        _quoteList = (quotesJson['results'] as List)
            .map((quoteJson) => Quote.fromJson(quoteJson))
            .toList();
      } else {
        throw ('HTTP ERROR $response');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getNextQuote() async {
    if (_shouldFetchQuotes()) {
      try {
        await _fetchQuotes();
        //start at the beginning of the page with new quotes
        _currentQuoteIndex = 0;
        _didLastFetchSucceed = true;
      } catch (e) {
        //keep looping over current page until new succesful fetch
        _currentQuoteIndex++;
        _didLastFetchSucceed = false;
      }
    } else {
      //jump to next quote in _quoteList
      _currentQuoteIndex++;
    }
    if (_quoteList.isNotEmpty) {
      currentQuote = _quoteList[_currentQuoteIndex % max(_quoteList.length, 1)];
    } else {
      // falling back on backup quotes if no quotes have been fetched at all
      currentQuote =
          _backupQuoteList[_currentQuoteIndex % _backupQuoteList.length];
    }
    notifyListeners();
  }

  ///This function loads the quotes that are stored in the assets folder in
  ///[_backupQuoteList], which can then be used as a fallback when there is no
  ///internet and the [_quoteList] is empty.
  Future<void> _loadBackupQuotes() async {
    final String backupFileContent =
        await rootBundle.loadString('assets/backup_quotes.json');
    final Map<String, dynamic> quotesJson = json.decode(backupFileContent);
    _backupQuoteList = (quotesJson['results'] as List)
        .map((quoteJson) => Quote.fromJson(quoteJson))
        .toList();
  }

  Future<void> initializeQuotes() async {
    if (_backupQuoteList.isEmpty) {
      await _loadBackupQuotes();
      _backupQuoteList.shuffle();
    }
    if (_quoteList.isEmpty) {
      await getNextQuote();
    }
  }
}

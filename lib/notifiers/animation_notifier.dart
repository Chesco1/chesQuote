import 'package:flutter/material.dart';

class AnimationNotifier extends ChangeNotifier {
  final Duration fadeDuration = const Duration(milliseconds: 750);

  bool _showQuoteText = false;
  bool _showQuoteAuthor = false;
  bool _showShareAndLikeRow = false;
  bool _showPrimaryButton = false;
  bool _ignoreButtonClicks = true;

  bool showQuoteText() => _showQuoteText;
  bool showQuoteAuthor() => _showQuoteAuthor;
  bool showShareAndLikeRow() => _showShareAndLikeRow;
  bool showPrimaryButton() => _showPrimaryButton;
  bool shouldIgnoreButtonClicks() => _ignoreButtonClicks;

  void setButtonClickability(bool clickable) {
    if (_ignoreButtonClicks == clickable) {
      _ignoreButtonClicks = !clickable;
      notifyListeners();
    }
  }

  Future<void> _setPrimaryButtonVisibility(bool visibility) async {
    if (_showPrimaryButton != visibility) {
      _showPrimaryButton = visibility;
      notifyListeners();
      await Future.delayed(fadeDuration);
    }
  }

  Future<void> _setQuoteTextVisibility(bool visibility) async {
    if (_showQuoteText != visibility) {
      _showQuoteText = visibility;
      notifyListeners();
      await Future.delayed(fadeDuration);
    }
  }

  Future<void> _setQuoteAuthorVisibility(bool visibility) async {
    if (_showQuoteAuthor != visibility) {
      _showQuoteAuthor = visibility;
      notifyListeners();
      await Future.delayed(fadeDuration);
    }
  }

  Future<void> _setShareAndLikeRowVisibility(bool visibility) async {
    if (_showShareAndLikeRow != visibility) {
      _showShareAndLikeRow = visibility;
      notifyListeners();
      await Future.delayed(fadeDuration);
    }
  }

  Future<void> showElements() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    await _setQuoteTextVisibility(true);
    await Future.delayed(const Duration(milliseconds: 200));
    await _setQuoteAuthorVisibility(true);
    await Future.delayed(const Duration(milliseconds: 1500));
    _setShareAndLikeRowVisibility(true);

    await _setPrimaryButtonVisibility(true);
    setButtonClickability(true);
  }

  Future<void> hideElements() async {
    setButtonClickability(false);
    await Future.delayed(const Duration(milliseconds: 200));

    ///Here we only await the last function so that all the items
    ///disappear at the same time. It is important to await and put last the
    ///function that has the longest duration
    _setPrimaryButtonVisibility(false);
    _setShareAndLikeRowVisibility(false);
    _setQuoteAuthorVisibility(false);
    await _setQuoteTextVisibility(false);
  }
}

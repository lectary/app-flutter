import 'package:flutter/material.dart';

/// ViewModel for handling state of the carousel
/// uses [ChangeNotifier] for propagating changes to UI components
class CarouselViewModel with ChangeNotifier {
  int _currentItemIndex = 0;

  int get currentItemIndex => _currentItemIndex;

  set currentItemIndex(int currentItemIndex) {
    _currentItemIndex = currentItemIndex;
    notifyListeners();
  }
}
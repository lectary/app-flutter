import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'package:carousel_slider/carousel_controller.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/screens/lectures/main_screen.dart';
import 'package:lectary/screens/lectures/vocable_search_screen.dart';
import 'package:lectary/utils/utils.dart';


/// ViewModel for handling state of the carousel
/// uses [ChangeNotifier] for propagating changes to UI components
class CarouselViewModel with ChangeNotifier {
  final LectureRepository _lectureRepository;

  /// Used primarily for jumping to other pages via the [VocableSearchScreen]
  CarouselController carouselController;

  bool vocableProgressEnabled = false;

  bool _hideVocableModeOn = false;
  bool get hideVocableModeOn => _hideVocableModeOn;
  set hideVocableModeOn(bool hideVocableModeOn) {
    _hideVocableModeOn = hideVocableModeOn;
    notifyListeners();
  }

  bool _slowModeOn = false;
  bool get slowModeOn => _slowModeOn;
  set slowModeOn(bool slowModeOn) {
    _slowModeOn = slowModeOn;
    notifyListeners();
  }

  bool _autoModeOn = false;
  bool get autoModeOn => _autoModeOn;
  set autoModeOn(bool autoModeOn) {
    _autoModeOn = autoModeOn;
    notifyListeners();
  }

  bool _loopModeOn = false;
  bool get loopModeOn => _loopModeOn;
  set loopModeOn(bool loopModeOn) {
    _loopModeOn = loopModeOn;
    notifyListeners();
  }

  List<Vocable> _currentVocables = List();
  List<Vocable> get currentVocables => _currentVocables;
  set currentVocables(List<Vocable> value) {
    _currentVocables = value;
    notifyListeners();
  }

  /// A copy of [currentVocables], used for filtering.
  /// If the filter result will be accepted [filteredVocables] will be assigned
  /// as new value of [currentVocables], otherwise discarded
  List<Vocable> _filteredVocables = List();
  List<Vocable> get filteredVocables => _filteredVocables;
  set filteredVocables(List<Vocable> value) {
    _filteredVocables = value;
  }

  /// used for displaying the name of the current loaded lecture/package (vocable-list)
  String _selectionTitle = "";
  String get selectionTitle => _selectionTitle;
  set selectionTitle(String value) {
    _selectionTitle = value;
    notifyListeners();
  }

  /// used in the carousel for keeping track of the current item/vocable
  int _currentItemIndex = 0;
  int get currentItemIndex => _currentItemIndex;
  set currentItemIndex(int currentItemIndex) {
    _currentItemIndex = currentItemIndex;
    notifyListeners();
  }

  /// Auto updating [Stream] by the [FloorDatabase], containing all local persisted [Lecture]
  Stream<List<Lecture>> _localLectures;

  /// Listener function for the stream of local persisted lectures used for updating the state of [LectureMainScreen]
  /// and its child appropriate (e.g. showing [LectureNotAvailableScreen])
  /// Loads all vocables whenever a new lecture list gets emitted
  /// Resets [_currentMediaItems] and [_selectionTitle] when no are available or got deleted
  void _localLectureStreamListener(List<Lecture> list) {
    if (list.isEmpty) {
      _currentVocables.clear();
      _selectionTitle = "";
      notifyListeners();
    }
    if (list.isNotEmpty) {
      loadAllVocables();
    }
  }

  /// Constructor with passed in [LectureRepository]
  CarouselViewModel({@required lectureRepository})
      : _lectureRepository = lectureRepository {
    _localLectures = _lectureRepository.watchAllLectures();
    _localLectures.listen(_localLectureStreamListener);
  }


  /// Auto updating [Stream] by the [FloorDatabase], containing all local persisted [Lecture]
  /// grouped as [LecturePackage] and properly sorted
  Stream<List<LecturePackage>> loadLocalLecturesAsStream() {
    return _lectureRepository.watchAllLectures().map((list) {
      // Sorting
      // 1) sort lessons with SORT-meta info by SORT
      List<Lecture> lecturesWithSortMeta = list.where((lecture) => lecture.sort != null).toList();
      lecturesWithSortMeta.sort((l1, l2) => l1.sort.compareTo(l2.sort));
      // 2) sort lessons without SORT-meta info lexicographic by lesson
      List<Lecture> lecturesWithoutSortMeta = list.where((lecture) => lecture.sort == null).toList();
      lecturesWithoutSortMeta.sort((l1, l2) => Utils.customCompareTo(l1.lesson, l2.lesson));
      // merge both sorted lists and group by lecture pack
      List<Lecture> allLectures = lecturesWithSortMeta;
      allLectures.addAll(lecturesWithoutSortMeta);
      List<LecturePackage> groupedLectureList = Utils.groupLecturesByPack(allLectures);
      // 3) sort lexicographic by packs
      groupedLectureList.sort((p1, p2) => Utils.customCompareTo(p1.title, p2.title));
      return groupedLectureList;
    });
  }

  /// Loads all persisted [Vocable] and notifies listeners
  /// Sets [_currentMediaItems], [_selectionTitle] and [selectionDidUpdate] appropriate and resets
  /// [_currentItemIndex] back to 0.
  /// The vocables are sorted only lexicographically.
  Future<void> loadAllVocables() async {
    _currentVocables = await _lectureRepository.findAllVocables();
    _currentItemIndex = 0;
    _selectionTitle = "Alle Vokabel";
    notifyListeners();
  }

  /// Loads all persisted [Vocable] from the passed [Lecture] and notifies listeners
  /// Sets [_currentMediaItems], [_selectionTitle] and [selectionDidUpdate] appropriate and resets
  /// [_currentItemIndex] back to 0.
  /// The vocables are sorted lexicographically and by metaData SORT if available.
  Future<void> loadVocablesOfLecture(Lecture lecture) async {
    List<Vocable> vocables = await _lectureRepository.findVocablesByLectureId(lecture.id);

    // sort vocables by sort-metaData if available
    List<Vocable> vocablesWithSort = vocables.where((vocable) => vocable.sort != null).toList();
    vocablesWithSort.sort((v1, v2) => v1.sort.compareTo(v2.sort));
    List<Vocable> vocablesWithoutSort = vocables.where((vocable) => vocable.sort == null).toList();

    List<Vocable> resultVocables = List.of({
      ...vocablesWithSort,
      ...vocablesWithoutSort
    });

    _currentVocables = resultVocables;
    _currentItemIndex = 0;
    _selectionTitle = lecture.lesson;
    notifyListeners();
  }

  /// Loads all persisted [Vocable] from the passed [LecturePackage] and notifies listeners
  /// Sets [_currentMediaItems], [_selectionTitle] and [selectionDidUpdate] appropriate and resets
  /// [_currentItemIndex] back to 0.
  /// The vocables are sorted lexicographically and by metaData SORT if available.
  Future<void> loadVocablesOfPackage(LecturePackage pack) async {
    List<Vocable> vocables = await _lectureRepository.findVocablesByLecturePack(pack.title);

    // sort vocables by sort-metaData if available
    List<Vocable> vocablesWithSort = vocables.where((vocable) => vocable.sort != null).toList();
    vocablesWithSort.sort((v1, v2) => v1.sort.compareTo(v2.sort));
    List<Vocable> vocablesWithoutSort = vocables.where((vocable) => vocable.sort == null).toList();

    List<Vocable> resultVocables = List.of({
      ...vocablesWithSort,
      ...vocablesWithoutSort
    });

    _currentVocables = resultVocables;
    _currentItemIndex = 0;
    _selectionTitle = pack.title;
    notifyListeners();
  }

  /// Filters the [List] of available [Vocable] by a [String]
  /// Filters vocable-name of [Vocable]
  /// Creates a temporary list with the filtered elements as references to the original list elements of
  /// [_currentMediaItems] and assigns it by reference again to [_filteredMediaItems] and notifies listeners
  /// Operations on the original list [_currentMediaItems] will therefore also affect the corresponding elements in [_filteredMediaItems]
  void filterVocables(String filter) {
    List<Vocable> tempListVocables = List();
    _currentVocables.forEach((voc) {
      if (voc.vocable.toLowerCase().contains(filter.toLowerCase())) {
        tempListVocables.add(voc);
      }
    });
    _filteredVocables = tempListVocables;
    notifyListeners();
  }

  /// Increases the [Vocable.vocableProgress] of the [Vocable] with the passed index
  /// Persists the changes in the database
  /// Returns a [Future] with type [Void]
  Future<void> increaseVocableProgress(int vocableIndex) async {
    Vocable vocableToUpdate = _currentVocables[vocableIndex];
    vocableToUpdate.vocableProgress = (vocableToUpdate.vocableProgress + 1) % 3;
    notifyListeners();
    try {
      await _lectureRepository.updateVocable(vocableToUpdate);
    } catch (e) {
      log("Updating progress of vocable: ${_currentVocables[vocableIndex]} failed: ${e.toString()}");
    }
  }

  /// Returns the index as [int] of a randomly chosen variable
  /// If [vocableProgressEnabled] is [True] then the [Vocable.vocableProgress] will be considered
  int chooseRandomVocable() {
    int rndPage = Utils.chooseRandomVocable(vocableProgressEnabled, _currentVocables);
    currentItemIndex = rndPage;
    return rndPage;
  }
}
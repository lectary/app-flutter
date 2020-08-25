import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:collection';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/models/search_result.dart';
import 'package:lectary/screens/lectures/main_screen.dart';
import 'package:lectary/screens/lectures/vocable_search_screen.dart';
import 'package:lectary/utils/utils.dart';
import 'package:collection/collection.dart';


/// ViewModel for handling state of the carousel
/// uses [ChangeNotifier] for propagating changes to UI components
class CarouselViewModel with ChangeNotifier {
  final LectureRepository _lectureRepository;

  /// Used primarily for jumping to other pages via the [VocableSearchScreen]
  CarouselController carouselController;

  bool _hideVocableModeOn = false;
  bool isVirtualLecture = false;
  bool vocableProgressEnabled = false;

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
    _searchResults = findDuplicatesAndConvert(value);
  }

  /// A copy of [currentVocables], used for filtering.
  /// If the filter result will be accepted [filteredVocables] will be assigned
  /// as new value of [currentVocables], otherwise discarded
  List<SearchResultPackage> _searchResults = List();
  List<SearchResultPackage> get searchResults => _searchResults;

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
  Stream<List<Lecture>> _localLecturesStream;
  StreamSubscription _localLectureStreamSubscription;

  List<Lecture> localLectures;

  /// Listener function for the stream of local persisted lectures used for updating the state of [LectureMainScreen]
  /// and its child appropriate (e.g. showing [LectureNotAvailableScreen]).
  /// Loads all vocables when a new lecture list gets emitted and no vocables are currently loaded.
  /// Resets [_currentVocables] and [_selectionTitle] when no lectures are available or got deleted
  void _localLectureStreamListener(List<Lecture> list) {
    localLectures = list;
    if (list.isEmpty) {
      _currentVocables.clear();
      _selectionTitle = "";
      notifyListeners();
    }
    if (list.isNotEmpty && _currentVocables.isEmpty) {
      loadAllVocables();
    }
  }


  /// Constructor with passed in [LectureRepository]
  CarouselViewModel({@required lectureRepository})
      : _lectureRepository = lectureRepository {
    _localLecturesStream = _lectureRepository.watchAllLectures();
    _localLectureStreamSubscription = _localLecturesStream.listen(_localLectureStreamListener);
  }

  @override
  void dispose() {
    _localLectureStreamSubscription.cancel();
    super.dispose();
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
  /// Returns a [Future] with [List] of type [Vocable].
  Future<List<Vocable>> loadAllVocables() async {
    _currentVocables = await _lectureRepository.findAllVocables();
    _currentItemIndex = 0;
    _selectionTitle = "Alle Vokabel";
    isVirtualLecture = false;
    notifyListeners();
    return _currentVocables;
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
    isVirtualLecture = false;
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
    isVirtualLecture = false;
    notifyListeners();
  }

  /// Filters the [List] of available [Vocable] by a [String]
  /// Filters vocable-name of [Vocable]
  /// Creates a temporary list with the filtered elements as references to the original list elements of
  /// [_currentMediaItems] and assigns it by reference again to [_filteredMediaItems] and notifies listeners
  /// Operations on the original list [_currentMediaItems] will therefore also affect the corresponding elements in [_filteredMediaItems]
  Future<void> filterVocables(String filter) async {
    List<Vocable> tempListVocables = List();
    _currentVocables.forEach((voc) {
      if (voc.vocable.toLowerCase().contains(filter.toLowerCase())) {
        tempListVocables.add(voc);
      }
    });
    filteredVocables = tempListVocables;
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

  int getIndexOfResult(SearchResult searchResult) {
    Vocable vocable = _filteredVocables.firstWhere((vocable) => vocable.id == searchResult.vocable.id);
    return _filteredVocables.indexOf(vocable);
  }

  void createNewVirtualLecture() {
    isVirtualLecture = true;
    _currentVocables = List.from(_filteredVocables);
  }


  /// Helper function for finding [Vocable] duplicates and converting them to
  /// [SearchResult] used by [VocableSearchScreen] for displaying.
  /// The function adds all vocables to a [HashMap], duplicates are saved together
  /// in a [List]. Then all elements of the map are iterated over and assigned to
  /// a final list of [SearchResult], where duplicates have their [MediaType] set,
  /// which is otherwise [Null].
  List<SearchResultPackage> findDuplicatesAndConvert(List<Vocable> vocables) {
    List<SearchResult> searchResultList = List();
    HashMap<String, List<Vocable>> duplicates = HashMap();
    vocables.forEach((voc) {
      if (duplicates.containsKey(voc.vocable)) {
        duplicates[voc.vocable].add(voc);
      } else {
        duplicates.putIfAbsent(voc.vocable, () => List.of({voc}));
      }
    });

    duplicates.forEach((key, value) {
      if (value.length == 1) {
        searchResultList.add(
          SearchResult(value[0])
        );
      } else {
        value.forEach((duplicate) {
          searchResultList.add(
            SearchResult(duplicate, mediaType: duplicate.mediaType)
          );
        });
      }
    });

    final groupedByLectureId = groupBy(searchResultList, (searchResult) => (searchResult as SearchResult).vocable.lectureId);
    List<SearchResultPackage> searchResultPackageList = List();
    groupedByLectureId.forEach((key, value) {
      String lectureName = localLectures.firstWhere((lecture) => lecture.id == key).lesson;
      searchResultPackageList.add(SearchResultPackage(lectureName, value));
    });

    // TODO sort

    return searchResultPackageList;
  }
}
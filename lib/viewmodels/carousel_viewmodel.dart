import 'dart:async';
import 'dart:developer';
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


/// ViewModel for handling state of the carousel.
/// Uses [ChangeNotifier] for propagating changes to UI components.
/// Has [LectureRepository] as dependency.
class CarouselViewModel with ChangeNotifier {
  final LectureRepository _lectureRepository;

  /// Used primarily for jumping to other pages via the [VocableSearchScreen]
  CarouselController carouselController;

  /// Used by the UI widget to know if it should display the lecture name next to the vocable
  bool isVirtualLecture = false;
  /// Used to know if vocable progress should be considered in [Utils.chooseRandomVocable]
  bool vocableProgressEnabled = false;
  /// Used by the model to differ between navigation and real-search of the vocable-search-screen
  bool searchForNavigationOnly = true;

  /// Modes used by [MediaViewer].
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

  /// A [List] of the current loaded [Vocable], that should be displayed in the [Carousel].
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
    _searchResults = _findDuplicatesAndConvert(value);
  }

  /// A copy of [currentVocables], used for filtering.
  /// If the filter result will be accepted [filteredVocables] will be assigned
  /// as new value of [currentVocables], otherwise discarded.
  List<SearchResultPackage> _searchResults = List();
  List<SearchResultPackage> get searchResults => _searchResults;

  /// Used for displaying the name of the current [Vocable]-selection list.
  String _selectionTitle = "";
  String get selectionTitle => _selectionTitle;
  set selectionTitle(String value) {
    _selectionTitle = value;
    notifyListeners();
  }

  /// Used in the carousel for keeping track of the index of the current [Vocable].
  int _currentItemIndex = 0;
  int get currentItemIndex => _currentItemIndex;
  set currentItemIndex(int currentItemIndex) {
    _currentItemIndex = currentItemIndex;
    notifyListeners();
  }

  /// Auto updating [Stream] by the [FloorDatabase], containing all local persisted [Lecture].
  Stream<List<Lecture>> _localLecturesStream;
  StreamSubscription _localLectureStreamSubscription;

  /// Used for retrieving the lecture name for corresponding vocables (e.g. when packaging
  /// vocables in [_findDuplicatesAndConvert]).
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

  /// Constructor with passed in [LectureRepository] dependency.
  /// Loads and listens to the [Stream] of local [Lecture].
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
  /// grouped as [LecturePackage] and properly sorted.
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

  /// Loads all persisted [Vocable] and notifies listeners.
  /// Sets [_currentVocables], [_selectionTitle] and [selectionDidUpdate] appropriate and resets
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

  /// Loads all persisted [Vocable] from the passed [Lecture] and notifies listeners.
  /// Sets [_currentVocables], [_selectionTitle] and [selectionDidUpdate] appropriate and resets
  /// [_currentItemIndex] back to 0.
  /// The vocables are sorted lexicographically and by metaData SORT if available.
  Future<void> loadVocablesOfLecture(Lecture lecture) async {
    List<Vocable> vocables = await _lectureRepository.findVocablesByLectureId(lecture.id);
    _currentVocables = _sortVocables(vocables);
    _currentItemIndex = 0;
    _selectionTitle = lecture.lesson;
    isVirtualLecture = false;
    notifyListeners();
  }

  /// Loads all persisted [Vocable] from the passed [LecturePackage] and notifies listeners.
  /// Sets [_currentVocables], [_selectionTitle] and [selectionDidUpdate] appropriate and resets
  /// [_currentItemIndex] back to 0.
  /// The vocables are sorted lexicographically and by metaData SORT if available.
  Future<void> loadVocablesOfPackage(LecturePackage pack) async {
    List<Vocable> vocables = await _lectureRepository.findVocablesByLecturePack(pack.title);
    _currentVocables = _sortVocables(vocables);
    _currentItemIndex = 0;
    _selectionTitle = pack.title;
    isVirtualLecture = false;
    notifyListeners();
  }

  /// Navigating to the selected vocable of the passed [SearchResult].
  /// If [searchForNavigationOnly] is false and the passed [currentFilter] is
  /// not empty, then a new virtual lecture is created.
  void navigateToVocable(SearchResult searchResult, String currentFilter) {
    int newIndex = getIndexOfResult(searchResult);

    if (currentFilter.isEmpty || searchForNavigationOnly) {
      carouselController.jumpToPage(newIndex);
    } else {
      // if search-term is not empty, a new "virtual"-lecture
      // containing the filter results is created and set
      log("Created new virtual lecture");
      _selectionTitle = "Suche: " + currentFilter;
      createNewVirtualLecture();
      // set index corresponding to the tabbed item index where
      // the carouselController should jump to after init
      _currentItemIndex = newIndex;
      notifyListeners();
    }
  }

  /// Filters the [List] of available [Vocable] ([_currentVocables]) by a [String].
  /// The vocables are filtered by their attribute [Vocable.vocable].
  /// Creates a temporary list with the filtered elements as references to the original list elements of
  /// [_currentVocables] and assigns it by reference again to [_filteredVocables] and notifies listeners.
  /// Operations on the original list [_currentVocables] will therefore also affect the corresponding elements in [_filteredVocables]
  Future<void> filterVocablesForNavigation(String filter) async {
    List<Vocable> localResults = List();
    _currentVocables.forEach((voc) {
      if (voc.vocable.toLowerCase().contains(filter.toLowerCase())) {
        localResults.add(voc);
      }
    });

    filteredVocables = localResults;
    notifyListeners();
  }

  /// Filters the [List] of available [Vocable] by a [String].
  /// This function first filters the current vocable selection ([_currentVocables])
  /// and then filters all persisted vocables.
  /// The vocables are filtered by their attribute [Vocable.vocable].
  /// Creates a temporary list with the filtered elements as references to the original list elements of
  /// [_currentVocables] and assigns it by reference again to [_filteredVocables] and notifies listeners.
  /// Operations on the original list [_currentVocables] will therefore also affect the corresponding elements in [_filteredVocables]
  Future<void> filterVocablesForSearch(String filter) async {
    List<Vocable> localResults = List();
    _currentVocables.forEach((voc) {
      if (voc.vocable.toLowerCase().contains(filter.toLowerCase())) {
        localResults.add(voc);
      }
    });

    List<Vocable> allVocables = await _lectureRepository.findAllVocables();
    localResults.forEach((localVoc) =>
        allVocables.removeWhere((globalVoc) => globalVoc.id == localVoc.id)
    );
    List<Vocable> globalResults = List();
    allVocables.forEach((voc) {
      if (voc.vocable.toLowerCase().contains(filter.toLowerCase())) {
        globalResults.add(voc);
      }
    });

    filteredVocables = List.of({...localResults, ...globalResults});
    notifyListeners();
  }

  /// Increases the [Vocable.vocableProgress] of the [Vocable] with the passed index.
  /// Updates the changes of the corresponding [Vocable] in the database.
  /// Returns a [Future] with type [Void].
  /// Exceptions of the database update are caught and ignored.
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

  /// Returns the index as [int] of the [Vocable] corresponding to the passed [SearchResult.vocable]
  int getIndexOfResult(SearchResult searchResult) {
    Vocable vocable = _filteredVocables.firstWhere((vocable) => vocable.id == searchResult.vocable.id);
    return _filteredVocables.indexOf(vocable);
  }

  /// Sets [isVirtualLecture] to true to indicate depending widgets that there is now a virtual lecture,
  /// which means that the lecture name has to be displayed together with the vocable.
  /// Assigns the current filter result [_filteredVocables] list as new value of [_currentVocables].
  void createNewVirtualLecture() {
    isVirtualLecture = true;
    _currentVocables = List.from(_filteredVocables);
  }

  /// Sorts a [List] of [Vocable].
  /// Returns a list of vocables, which first contains all vocables sorted by
  /// [Vocable.sort] and then all vocables sorted lexicographically by [Vocable.vocableSort].
  /// Asserts that the vocables are already sorted lexicographically by the database query.
  List<Vocable> _sortVocables(List<Vocable> vocables) {
    // extract and sort sublist of vocables with or without vocable.sort value
    List<Vocable> vocablesWithSort = vocables.where((vocable) => vocable.sort != null).toList();
    vocablesWithSort.sort((v1, v2) => v1.sort.compareTo(v2.sort));
    // assert that the vocables are already sorted via the database query
    List<Vocable> vocablesWithoutSort = vocables.where((vocable) => vocable.sort == null).toList();

    List<Vocable> resultVocables = List.of({
      ...vocablesWithSort,
      ...vocablesWithoutSort
    });

    return resultVocables;
  }

  /// Helper function for finding [Vocable] duplicates, converting them to
  /// [SearchResult] and grouping them to [SearchResultPackage], which is
  /// used by [VocableSearchScreen] for displaying.
  /// Returns a [List] of [SearchResultPackage].
  /// Duplicated vocables have their [MediaType] set in the corresponding
  /// [SearchResult.mediaType], which is [Null] otherwise.
  /// Asserts that the vocable list is already sorted as specified
  List<SearchResultPackage> _findDuplicatesAndConvert(List<Vocable> vocables) {
    // Iterating over the list and saving the vocables in a hashMap of
    // type <String, bool>. If a vocable is already saved, then the value
    // is set to true to indicate that there are duplicates for this vocable,
    // which is saved as key.
    Map<String, bool> hasDuplicates = HashMap();
    vocables.forEach((voc) {
      if (hasDuplicates.containsKey(voc.vocable)) {
        hasDuplicates[voc.vocable] = true;
      } else {
        hasDuplicates.putIfAbsent(voc.vocable, () => false);
      }
    });

    // Mapping the vocable list to the corresponding SearchResult list
    // with the media type set for duplicates
    List<SearchResult> searchResultList = vocables.map((vocable) {
      if (hasDuplicates[vocable.vocable]) {
        return SearchResult(vocable, mediaType: vocable.mediaType);
      } else {
        return SearchResult(vocable);
      }
    }).toList();

    // grouping the searchResults after lecture id, and then replacing the id
    // with the corresponding lecture name, by a lookup in the list of local lectures
    final groupedByLectureId = groupBy(searchResultList, (searchResult) => (searchResult as SearchResult).vocable.lectureId);
    List<SearchResultPackage> searchResultPackageList = List();
    groupedByLectureId.forEach((key, value) {
      String lectureName = localLectures.firstWhere((lecture) => lecture.id == key).lesson;
      searchResultPackageList.add(SearchResultPackage(lectureName, value));
    });

    return searchResultPackageList;
  }
}
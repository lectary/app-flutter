import 'dart:async';
import 'dart:developer';
import 'dart:collection';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/models/search_result.dart';
import 'package:lectary/screens/lectures/main_screen.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/utils/selection_type.dart';
import 'package:lectary/utils/utils.dart';
import 'package:collection/collection.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// ViewModel for handling state of the carousel.
/// Uses [ChangeNotifier] for propagating changes to UI components.
/// Has [LectureRepository] as dependency.
class CarouselViewModel with ChangeNotifier {
  final LectureRepository _lectureRepository;
  final SettingViewModel _settingViewModel;

  /// Used primarily for jumping to other pages via the [VocableSearchScreen]
  CarouselController carouselController;

  /// Used to interrupt videos or animations of the carousel when another route is pushed
  bool _interrupted = false;
  bool get interrupted => _interrupted;
  set interrupted(bool interrupted) {
    _interrupted = interrupted;
    notifyListeners();
  }

  /// Represents the current [Selection] (i.e. the selection of loaded vocables).
  Selection currentSelection;
  /// The index of the vocable on which the carousel should start on app-start.
  /// Will be resetted by the carousel after the first use.
  int initialCarouselValue = 0;

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
    if (!isVirtualLecture) _saveItemIndexPref(currentItemIndex);
  }

  /// Auto updating [Stream] by the [FloorDatabase], containing all local persisted [Lecture].
  Stream<List<Lecture>> _localLecturesStream;
  StreamSubscription _localLectureStreamSubscription;

  /// Used for retrieving the lecture name for corresponding vocables (e.g. when packaging
  /// vocables in [_findDuplicatesAndConvert]).
  List<Lecture> localLectures;

  /// Used for global search and loaded when the search is first used.
  List<Vocable> _allLocalVocables = List();

  void clearAllLocalVocables() {
    _allLocalVocables.clear();
  }

  /// Listener function for the stream of local persisted lectures used for updating the state of [LectureMainScreen]
  /// and its child appropriate (e.g. showing [LectureNotAvailableScreen]).
  /// Loads all vocables when a new lecture list gets emitted and no vocables are currently loaded.
  /// Resets [_currentVocables] and [_selectionTitle] when no lectures are available or got deleted
  void _localLectureStreamListener(List<Lecture> list) {
    localLectures = list;

    if (list.isEmpty) {
      _currentVocables.clear();
      _selectionTitle = "";
      _saveSelection(null);
      notifyListeners();
    }
    // ToDo review - disabling due to interferences with init-loading mechanic during debugging
    // load all vocables when there is no current selection and dont save it as
    // new selection
    /*if (list.isNotEmpty && currentSelection == null) {
      loadAllVocables(saveSelection: false);
      log("loaded all vocables");
    }*/
  }

  /// Constructor with passed in [LectureRepository] dependency.
  /// Loads and listens to the [Stream] of local [Lecture].
  CarouselViewModel({@required lectureRepository, @required settingViewModel})
      : _lectureRepository = lectureRepository, _settingViewModel = settingViewModel {
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
  /// Vocables are sorted only lexicographically.
  /// Sets [_currentVocables], [_selectionTitle] appropriately and [isVirtualLecture] to false.
  ///
  /// Further resets [currentItemIndex] back to 0 and saves it in the cache.
  /// Saves the metaInfo about the loaded vocable list as new [Selection] in the cache.
  /// The optional parameter [saveSelection] can be used to avoid saving [currentItemIndex] or [Selection]
  /// if they are already restored from cache by other means.
  ///
  /// Returns a [Future] with [List] of type [Vocable].
  Future<List<Vocable>> loadAllVocables({bool saveSelection=true}) async {
    _currentVocables = await _lectureRepository.findAllVocables();
    _selectionTitle = AppLocalizations.current.allVocables;
    isVirtualLecture = false;
    if (saveSelection) {
      _currentItemIndex = 0;
      await _saveItemIndexPref(0);
      await _saveSelection(Selection.all());
    }
    notifyListeners();
    log("loaded all vocables");
    return _currentVocables;
  }

  /// Loads all persisted [Vocable] from the passed [Lecture.id] and [Lecture.lesson] and notifies listeners.
  /// Vocables are sorted only lexicographically and by metaData SORT if available.
  /// Sets [_currentVocables], [_selectionTitle] appropriately and [isVirtualLecture] to false.
  ///
  /// Further resets [currentItemIndex] back to 0 and saves it in the cache.
  /// Saves the metaInfo about the loaded vocable list as new [Selection] in the cache.
  /// The optional parameter [saveSelection] can be used to avoid saving [currentItemIndex] or [Selection]
  /// if they are already restored from cache by other means.
  ///
  /// Returns a [Future] with [List] of type [Vocable].
  Future<List<Vocable>> loadVocablesOfLecture(int lectureId, String lesson, {bool saveSelection=true}) async {
    List<Vocable> vocables = await _lectureRepository.findVocablesByLectureId(lectureId);
    _currentVocables = _sortVocables(vocables);
    _selectionTitle = lesson;
    isVirtualLecture = false;
    if (saveSelection) {
      _currentItemIndex = 0;
      await _saveItemIndexPref(0);
      await _saveSelection(Selection.lecture(lectureId, lesson));
    }
    notifyListeners();
    log("loaded lecture $lesson");
    return _currentVocables;
  }

  /// Loads all persisted [Vocable] from the passed [LecturePackage.title] and notifies listeners.
  /// Vocables are sorted only lexicographically and by metaData SORT if available.
  /// Sets [_currentVocables], [_selectionTitle] appropriately and [isVirtualLecture] to false.
  ///
  /// Further resets [currentItemIndex] back to 0 and saves it in the cache.
  /// Saves the metaInfo about the loaded vocable list as new [Selection] in the cache.
  /// The optional parameter [saveSelection] can be used to avoid saving [currentItemIndex] or [Selection]
  /// if they are already restored from cache by other means.
  ///
  /// Returns a [Future] with [List] of type [Vocable].
  Future<List<Vocable>> loadVocablesOfPackage(String packTitle, {bool saveSelection=true}) async {
    List<Vocable> vocables = await _lectureRepository.findVocablesByLecturePack(packTitle);
    _currentVocables = _sortVocables(vocables);
    _selectionTitle = packTitle;
    isVirtualLecture = false;
    if (saveSelection) {
      _currentItemIndex = 0;
      await _saveItemIndexPref(0);
      await _saveSelection(Selection.package(packTitle));
    }
    notifyListeners();
    log("loaded package $packTitle");
    return _currentVocables;
  }

  /// Saves [itemIndex] in the [SharedPreferences].
  Future<void> _saveItemIndexPref(int itemIndex) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(Constants.keyItemIndex, itemIndex);
  }

  /// Loads the itemIndex saved in the [SharedPreferences] and sets
  /// [_currentItemIndex] and [initialCarouselValue].
  Future<void> _restoreItemIndexPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int index = prefs.get(Constants.keyItemIndex) ?? 0;
    _currentItemIndex = index;
    initialCarouselValue = index;
  }

  /// Saves the passed [Selection] in the [SharedPreferences].
  /// [SelectionType.all] gets saved with the value 'all'.
  /// [SelectionType.package] gets saved with the value 'package:<package-title>'.
  /// [SelectionType.lecture] gets saved with the value 'lecture:<lecture-id>:<lecture-lesson>'.
  /// If [Null] is passed, then the saved selection will be removed.
  Future<void> _saveSelection(Selection selection) async {
    // save selection in the viewModel to be available for UI-widgets
    currentSelection = selection;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    // remove key (and possible value) if null is passed as selection-value
    if (selection == null) {
      return await prefs.remove(Constants.keySelection);
    }
    // save needed selection info corresponding to the SelectionType
    switch (selection.type) {
      case SelectionType.all:
        await prefs.setString(Constants.keySelection, Constants.keySelectionAll);
        break;
      case SelectionType.package:
        await prefs.setString(Constants.keySelection, "${Constants.keySelectionPackage}:${selection.packTitle}");
        break;
      case SelectionType.lecture:
        await prefs.setString(Constants.keySelection, "${Constants.keySelectionLecture}:${selection.lectureId}:${selection.lesson}");
        break;
    }
  }

  /// Loads the last vocable-selection from [SharedPreferences].
  /// Returns a [Future] of type [Selection] or [Null] if no last selection
  /// is available.
  Future<Selection> loadLastSelection() async {
    // load selection value
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String selectionString = prefs.getString(Constants.keySelection);

    if (selectionString == null) {
      return null;
    } else {
      if (selectionString == Constants.keySelectionAll) {
        return Selection.all();
      }

      // safety check
      if (!selectionString.contains(Constants.keySelectionPackage) &&
          !selectionString.contains(Constants.keySelectionLecture)) return null;

      // retrieve selection type 'package' or 'lecture' by index to be independent of package/lecture names
      int firstIndex = selectionString.indexOf(":");
      String selection = selectionString.substring(0, firstIndex);

      if (selection == Constants.keySelectionPackage) {
        // extract pack title
        String packTitle = selectionString.substring(firstIndex + 1);
        return Selection.package(packTitle);
      }

      if (selection == Constants.keySelectionLecture) {
        // extract lectureId and name, using indexOf to be independent of lecture name
        String selectionSubString = selectionString.substring(firstIndex + 1);
        int secondIndex = selectionSubString.indexOf(":");
        int id = int.parse(selectionSubString.substring(0, secondIndex));
        String lesson = selectionSubString.substring(secondIndex + 1);
        return Selection.lecture(id, lesson);
      }

      return null;
    }
  }

  /// Method used at app-start to load vocables.
  /// First loads the last vocable-selection if available.
  /// If no last selection is available, then all vocables will be loaded.
  Future<List<Vocable>> initVocables() async {
    Selection lastSelection = await loadLastSelection();
    log("loaded last selection");

    if (lastSelection == null) {
      return await loadAllVocables();
    }

    // restore and set itemIndex and initialValue for the carousel
    await _restoreItemIndexPref();

    switch (lastSelection.type) {
      case SelectionType.all:
        return await loadAllVocables(saveSelection: false);
      case SelectionType.package:
        return await loadVocablesOfPackage(lastSelection.packTitle, saveSelection: false);
      case SelectionType.lecture:
        return await loadVocablesOfLecture(lastSelection.lectureId, lastSelection.lesson, saveSelection: false);
      default:
        return await loadAllVocables();
    }
  }

  /// Navigating to the selected vocable of the passed [SearchResult].
  /// If [searchForNavigationOnly] is false and the passed [currentFilter] is
  /// not empty, then a new virtual lecture is created.
  void navigateToVocable(SearchResult searchResult, String currentFilter) {
    int newIndex = _getIndexOfResult(searchResult);

    if (currentFilter.isEmpty || searchForNavigationOnly) {
      carouselController.jumpToPage(newIndex);
    } else {
      // if search-term is not empty, a new "virtual"-lecture
      // containing the filter results is created and set
      log("Created new virtual lecture");
      _selectionTitle = _settingViewModel.settingUppercase
          ? (AppLocalizations.current.searchLabel + currentFilter).toUpperCase()
          : AppLocalizations.current.searchLabel + currentFilter;
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
    if (_allLocalVocables.isEmpty) {
      _allLocalVocables = await _lectureRepository.findAllVocables();
      log("loaded all local vocables");

    }

    // filter the list of current selected vocables
    List<Vocable> localResults = List();
    _currentVocables.forEach((voc) {
      if (voc.vocable.toLowerCase().contains(filter.toLowerCase())) {
        localResults.add(voc);
      }
    });

    // remove all vocables in the global list that are already in the local one
    localResults.forEach((localVoc) =>
        _allLocalVocables.removeWhere((globalVoc) => globalVoc.id == localVoc.id)
    );
    // filter remaining vocables in the global list
    List<Vocable> globalResults = List();
    _allLocalVocables.forEach((voc) {
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
  int _getIndexOfResult(SearchResult searchResult) {
    if (searchForNavigationOnly) {
      Vocable vocable = _currentVocables.firstWhere((vocable) => vocable.id == searchResult.vocable.id);
      return _currentVocables.indexOf(vocable);
    } else {
      Vocable vocable = _filteredVocables.firstWhere((vocable) => vocable.id == searchResult.vocable.id);
      return _filteredVocables.indexOf(vocable);
    }
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
    List<SearchResultPackage> tmpList = List();
    final groupedByLectureId = groupBy(searchResultList, (searchResult) => (searchResult as SearchResult).vocable.lectureId);
    groupedByLectureId.forEach((key, value) {
      String lectureName = localLectures.firstWhere((lecture) => lecture.id == key).lesson;
      tmpList.add(SearchResultPackage(lectureName, value));
    });

    // sorting grouped lists excluding first one
    List<SearchResultPackage> searchResultPackageList = List();
    if (tmpList.length > 1) {
      searchResultPackageList.add(tmpList.removeAt(0));
      tmpList.sort((lec1, lec2) => Utils.customCompareTo(lec1.lectureTitle, lec2.lectureTitle));
    }
    searchResultPackageList.addAll(tmpList);

    return searchResultPackageList;
  }
}
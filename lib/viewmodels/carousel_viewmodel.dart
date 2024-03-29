import 'dart:async';
import 'dart:collection';
import 'dart:developer';
import 'dart:io';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:collection/collection.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/models/media_type_enum.dart';
import 'package:lectary/models/search_result.dart';
import 'package:lectary/models/selection_type.dart';
import 'package:lectary/screens/lectures/main_screen.dart';
import 'package:lectary/screens/management/lecture_management_screen.dart';
import 'package:lectary/screens/settings/settings_screen.dart';
import 'package:lectary/utils/constants.dart';
import 'package:lectary/utils/utils.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


/// ViewModel for handling state of the carousel.
/// Uses [ChangeNotifier] for propagating changes to UI components.
/// Has [LectureRepository] as dependency.
class CarouselViewModel with ChangeNotifier {
  final LectureRepository _lectureRepository;
  SettingViewModel? _settingViewModel;
  bool? _settingPlayMediaWithSound; // acts like a filter for this setting, to avoid global rebuild of carousel

  /// Updates the local reference to [SettingViewModel].
  void updateSettings(SettingViewModel settingViewModel) {
    _settingViewModel = settingViewModel;
    if (_settingPlayMediaWithSound == null || _settingPlayMediaWithSound == settingViewModel.settingPlayMediaWithSound) {
      listenOnLocalLectures();
      loadAllVocables();
    }
    _settingPlayMediaWithSound = _settingViewModel?.settingPlayMediaWithSound;
    log("updated settings reference in carouselViewModel");
  }

  /// Used primarily for jumping to other pages via the [VocableSearchScreen]
  late CarouselController carouselController;

  /// Used to interrupt videos or animations of the carousel when another route is pushed
  bool _interrupted = false;
  bool get interrupted => _interrupted;
  set interrupted(bool interrupted) {
    _interrupted = interrupted;
    notifyListeners();
  }
  /// Double checking variable used with the drawer to ensure that the drawer does not set [interrupted] when
  /// navigating to [LectureManagementScreen] or [SettingsScreen].
  /// This is because the drawer is not recognized as route, and therefor sets [interrupted] in its dispose method to false.
  /// But the route change is recognized before the drawer gets disposed, resulting in a interfering setting of [interrupted].
  bool _interruptedCauseNavigation = false;
  bool get interruptedCauseNavigation => _interruptedCauseNavigation;
  set interruptedCauseNavigation(bool interruptedCauseNavigation) {
    _interruptedCauseNavigation = interruptedCauseNavigation;
    notifyListeners();
  }

  /// Represents the current [Selection] (i.e. the selection of loaded vocables).
  Selection? _currentSelection;
  Selection? get currentSelection => _currentSelection;
  set currentSelection(Selection? currentSelection) {
    _currentSelection = currentSelection;
    notifyListeners();
  }
  /// The index of the vocable on which the carousel should start on app-start.
  /// Will be resetted by the carousel after the first use.
  int initialCarouselValue = 0;
  /// Is [True] during initial vocable loading, to ensure
  /// that streams from the drawer are not interfering loading of selection or itemIndex.
  bool _initialization = false;

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
  List<Vocable> _currentVocables = [];
  List<Vocable> get currentVocables => _currentVocables;
  set currentVocables(List<Vocable> value) {
    _currentVocables = value;
    notifyListeners();
  }

  /// A copy of [currentVocables], used for filtering.
  /// If the filter result will be accepted [filteredVocables] will be assigned
  /// as new value of [currentVocables], otherwise discarded
  List<Vocable> _filteredVocables = [];
  List<Vocable> get filteredVocables => _filteredVocables;

  void clearFilteredVocables() {
    _filteredVocables.clear();
  }
  void copyCurrentToFilteredVocables() {
    // create a new! list with currentVocables
    _filteredVocables = List.from(_currentVocables);
    _searchResults = _findDuplicatesAndConvert(_filteredVocables);
  }

  /// /// A copy of [currentVocables], but for display purposes only.
  /// Contains the same vocables as [filteredVocables] but packaged as [List] of type [SearchResultItem].
  List<SearchResultItem> _searchResults = [];
  List<SearchResultItem> get searchResults => _searchResults;

  /// Used in the carousel for keeping track of the index of the current [Vocable].
  int _currentItemIndex = 0;
  int get currentItemIndex => _currentItemIndex;
  set currentItemIndex(int currentItemIndex) {
    _currentItemIndex = currentItemIndex;
    notifyListeners();
    if (!isVirtualLecture) _saveItemIndexPref(currentItemIndex);
  }

  /// Auto updating [Stream] by the [FloorDatabase], containing all local persisted [Lecture].
  late Stream<List<Lecture>> _localLecturesStream;
  StreamSubscription? _localLectureStreamSubscription;

  /// Used for retrieving the lecture name for corresponding vocables (e.g. when packaging
  /// vocables in [_findDuplicatesAndConvert]).
  List<Lecture>? localLectures;

  /// Used for global search and loaded when the search is first used.
  List<Vocable> _allLocalVocables = [];

  void clearAllLocalVocables() {
    _allLocalVocables.clear();
  }

  /// Cache for app directory, needed for resolving relative file path of vocables
  late Future<Directory> _applicationDirectory;
  Future<Directory> get applicationDirectory => _applicationDirectory;

  void initApplicationDirectory() async {
    _applicationDirectory = getApplicationDocumentsDirectory().whenComplete(() => notifyListeners());
  }

  /// Constructor with passed in [LectureRepository] dependency.
  /// Loads and listens to the [Stream] of local [Lecture].
  CarouselViewModel({required lectureRepository}) : _lectureRepository = lectureRepository {
    initApplicationDirectory();
  }

  @override
  void dispose() {
    _localLectureStreamSubscription?.cancel();
    super.dispose();
  }

  /// Retrieves a [Stream] of the [List] of all local persisted [Lecture].
  /// Additionally listens to changes via [_localLectureStreamListener].
  void listenOnLocalLectures() {
    if (_localLectureStreamSubscription != null) _localLectureStreamSubscription!.cancel();
    _localLecturesStream = _lectureRepository.watchAllLectures();
    _localLectureStreamSubscription = _localLecturesStream.listen(_localLectureStreamListener);
    log("carousel view model instances!");
  }

  /// Listener function for the stream of local persisted lectures used for updating the state of [LectureMainScreen]
  /// and its child appropriate (e.g. showing [LectureNotAvailableScreen]).
  /// Loads all vocables when a new lecture list gets emitted and no vocables are currently loaded.
  /// Resets [_currentVocables] when no lectures are available or got deleted
  void _localLectureStreamListener(List<Lecture> list) {
    list = list.where((lecture) => lecture.langMedia == _settingViewModel!.settingLearningLanguage).toList();
    localLectures = list;

    if (list.isEmpty) {
      _currentVocables.clear();
      currentSelection = null;
      _saveSelection(null);
      notifyListeners();
    }
    // based on the current selection, load all vocables or reload current selection
    if (list.isNotEmpty && !_initialization) {
      if (currentSelection == null) {
        log("loading all vocables");
        loadAllVocables();
        return;
      }
      if (currentSelection!.type == SelectionType.all) {
        log("reloading all vocables selection");
        loadAllVocables(saveSelection: false);
        return;
      }
      if (currentSelection!.type == SelectionType.package && currentSelection!.packTitle == list[0].pack) {
        log("reloading package selection");
        reloadCurrentSelection();
        return;
      }
    }
  }

  /// Auto updating [Stream] by the [FloorDatabase], containing all local persisted [Lecture]
  /// grouped as [LecturePackage] and properly sorted.
  Stream<List<LecturePackage>>? loadLocalLecturesAsStream() {
    if (_settingViewModel == null) return null;

    String langMedia = _settingViewModel!.settingLearningLanguage;
    return _lectureRepository.watchAllLectures().map((list) {
      // filtering lectures by Settings.settingLearningLanguage
      list = list.where((lecture) => lecture.langMedia == langMedia).toList();
      // Sorting
      // 1) sort lessons with SORT-meta info by SORT
      List<Lecture> lecturesWithSortMeta = list.where((lecture) => lecture.sort != null).toList();
      lecturesWithSortMeta.sort((l1, l2) => l1.sort!.compareTo(l2.sort!));
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
  /// Sets [_currentVocables] appropriately and [isVirtualLecture] to false.
  ///
  /// Further resets [currentItemIndex] back to 0 and saves it in the cache.
  /// Saves the metaInfo about the loaded vocable list as new [Selection] in the cache.
  /// The optional parameter [saveSelection] can be used to avoid saving [currentItemIndex] or [Selection]
  /// if they are already restored from cache by other means.
  ///
  /// Returns a [Future] with [List] of type [Vocable].
  Future<List<Vocable>> loadAllVocables({bool saveSelection=true}) async {
    _currentVocables = await _lectureRepository.findVocablesByLangMedia(
      _settingViewModel!.settingLearningLanguage
    );
    isVirtualLecture = false;
    Selection newSelection = Selection.all();
    currentSelection = newSelection;
    _currentItemIndex = 0;
    if (saveSelection) {
      await _saveItemIndexPref(0);
      await _saveSelection(newSelection);
    }
    notifyListeners();
    log("loaded all vocables");
    return _currentVocables;
  }

  /// Loads all persisted [Vocable] from the passed [Lecture.id] and [Lecture.lesson] and notifies listeners.
  /// Vocables are sorted only lexicographically and by metaData SORT if available.
  /// Sets [_currentVocables] appropriately and [isVirtualLecture] to false.
  ///
  /// Further resets [currentItemIndex] back to 0 and saves it in the cache.
  /// Saves the metaInfo about the loaded vocable list as new [Selection] in the cache.
  /// The optional parameter [saveSelection] can be used to avoid saving [currentItemIndex] or [Selection]
  /// if they are already restored from cache by other means.
  ///
  /// Returns a [Future] with [List] of type [Vocable].
  Future<List<Vocable>> loadVocablesOfLecture(int lectureId, String? lesson, {bool saveSelection=true}) async {
    List<Vocable> vocables = await _lectureRepository.findVocablesByLectureIdAndLangMedia(
        lectureId,
        _settingViewModel!.settingLearningLanguage
    );
    _currentVocables = _sortVocables(vocables);
    isVirtualLecture = false;
    Selection newSelection = Selection.lecture(lectureId, lesson);
    currentSelection = newSelection;
    _currentItemIndex = 0;
    if (saveSelection) {
      await _saveItemIndexPref(0);
      await _saveSelection(newSelection);
    }
    notifyListeners();
    log("loaded lecture $lesson");
    return _currentVocables;
  }

  /// Loads all persisted [Vocable] from the passed [LecturePackage.title] and notifies listeners.
  /// Vocables are sorted only lexicographically and by metaData SORT if available.
  /// Sets [_currentVocables] appropriately and [isVirtualLecture] to false.
  ///
  /// Further resets [currentItemIndex] back to 0 and saves it in the cache.
  /// Saves the metaInfo about the loaded vocable list as new [Selection] in the cache.
  /// The optional parameter [saveSelection] can be used to avoid saving [currentItemIndex] or [Selection]
  /// if they are already restored from cache by other means.
  ///
  /// Returns a [Future] with [List] of type [Vocable].
  Future<List<Vocable>> loadVocablesOfPackage(String packTitle, {bool saveSelection=true}) async {
    List<Vocable> vocables = await _lectureRepository.findVocablesByLecturePackAndLangMedia(
        packTitle,
        _settingViewModel!.settingLearningLanguage
    );
    _currentVocables = _sortVocables(vocables);
    isVirtualLecture = false;
    Selection newSelection = Selection.package(packTitle);
    currentSelection = newSelection;
    _currentItemIndex = 0;
    if (saveSelection) {
      await _saveItemIndexPref(0);
      await _saveSelection(newSelection);
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
    int index = prefs.get(Constants.keyItemIndex) as int? ?? 0;
    _currentItemIndex = index;
    initialCarouselValue = index;
  }

  /// Saves the passed [Selection] in the [SharedPreferences].
  /// [SelectionType.all] gets saved with the value 'all'.
  /// [SelectionType.package] gets saved with the value 'package:<package-title>'.
  /// [SelectionType.lecture] gets saved with the value 'lecture:<lecture-id>:<lecture-lesson>'.
  /// If [Null] is passed, then the saved selection will be removed.
  Future<void> _saveSelection(Selection? selection) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // remove key (and possible value) if null is passed as selection-value
    if (selection == null) {
      await prefs.remove(Constants.keySelection);
      return;
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
      default:
        break;
    }
  }

  /// Method for reloading current selection.
  /// Main purpose is for reloading current state after the setting-resetLearningProgress.
  Future<void> reloadCurrentSelection() async {
    if (currentSelection == null) return;

    switch (currentSelection!.type) {
      case SelectionType.all:
        await loadAllVocables(saveSelection: false);
        break;
      case SelectionType.package:
        await loadVocablesOfPackage(currentSelection!.packTitle!, saveSelection: false);
        break;
      case SelectionType.lecture:
        await loadVocablesOfLecture(currentSelection!.lectureId!, currentSelection!.lesson, saveSelection: false);
        break;
      default:
        return;
    }
  }

  /// Loads the last vocable-selection from [SharedPreferences].
  /// Returns a [Future] of type [Selection] or [Null] if no last selection
  /// is available.
  Future<Selection?> loadLastSelection() async {
    // load selection value
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectionString = prefs.getString(Constants.keySelection);

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
    _initialization = true;

    Selection? lastSelection = await loadLastSelection();
    log("loaded last selection: ${lastSelection == null ? "<null>" : lastSelection.type}");

    if (lastSelection == null) {
      _initialization = false;
      return await loadAllVocables();
    }

    currentSelection = lastSelection;

    List<Vocable> vocables;
    // load vocables and restore itemIndex/initialValue for the carousel
    switch (lastSelection.type) {
      case SelectionType.all:
        vocables = await loadAllVocables(saveSelection: false);
        await _restoreItemIndexPref();
        break;
      case SelectionType.package:
        vocables = await loadVocablesOfPackage(lastSelection.packTitle!, saveSelection: false);
        await _restoreItemIndexPref();
        break;
      case SelectionType.lecture:
        vocables = await loadVocablesOfLecture(lastSelection.lectureId!, lastSelection.lesson, saveSelection: false);
        await _restoreItemIndexPref();
        break;
      default:
        vocables = await loadAllVocables();
        await _restoreItemIndexPref();
        break;
    }

    _initialization = false;
    return vocables;
  }

  /// Sorts a [List] of [Vocable].
  /// Returns a list of vocables, which first contains all vocables sorted by
  /// [Vocable.sort] and then all vocables sorted lexicographically by [Vocable.vocableSort].
  /// Asserts that the vocables are already sorted lexicographically by the database query.
  List<Vocable> _sortVocables(List<Vocable> vocables) {
    // extract and sort sublist of vocables with or without vocable.sort value
    List<Vocable> vocablesWithSort = vocables.where((vocable) => vocable.sort != null).toList();
    vocablesWithSort.sort((v1, v2) => v1.sort!.compareTo(v2.sort!));
    // assert that the vocables are already sorted via the database query
    List<Vocable> vocablesWithoutSort = vocables.where((vocable) => vocable.sort == null).toList();

    List<Vocable> resultVocables = List.of({
      ...vocablesWithSort,
      ...vocablesWithoutSort
    });

    return resultVocables;
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
      createNewVirtualLecture();
      currentSelection = Selection.search(currentFilter, _currentSelection);
      // set index corresponding to the tabbed item index where
      // the carouselController should jump to after init
      _currentItemIndex = newIndex;
      notifyListeners();
    }
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

  /// Closes current virtual lecture.
  /// Sets [isVirtualLecture] to [False].
  /// Restores selection and itemIndex that where set prior to the virtual lecture.
  void closeVirtualLecture() async {
    if (!isVirtualLecture && _currentSelection!.type!= SelectionType.search) return;
    isVirtualLecture = false;
    // retrieve last selection
    _currentSelection = _currentSelection!.originSelection;
    // reload selection
    await reloadCurrentSelection();
  }

  /// Filters the [List] of available [Vocable] ([_currentVocables]) by a [String].
  /// The vocables are filtered by their attribute [Vocable.vocable].
  /// Creates a temporary list with the filtered elements as references to the original list elements of
  /// [_currentVocables] and assigns it by reference again to [_filteredVocables] and notifies listeners.
  /// Operations on the original list [_currentVocables] will therefore also affect the corresponding elements in [_filteredVocables]
  Future<void> filterVocablesForNavigation(String filter) async {
    List<Vocable> localResults = [];
    _currentVocables.forEach((voc) {
      if (voc.vocable.toLowerCase().contains(filter.toLowerCase())) {
        localResults.add(voc);
      }
    });
    _filteredVocables = localResults;
    _searchResults = _findDuplicatesAndConvert(_filteredVocables);
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
    // If the filter is empty, early return with the current list of vocable,
    // with determined duplicates and converted to type [SearchResult]
    if (filter.isEmpty) {
      _searchResults = _findDuplicatesAndConvert(List.from(_currentVocables));
      notifyListeners();
      return;
    }

    // Load all local variables if not already done.
    if (_allLocalVocables.isEmpty) {
      _allLocalVocables = await _lectureRepository.findVocablesByLangMedia(_settingViewModel!.settingLearningLanguage);
      log("loaded all local vocables");
    }

    // Local copy for manipulating
    List<Vocable> allVocables = List.from(_allLocalVocables);

    // filter the list of current selected vocables
    List<Vocable> localResults = [];
    _currentVocables.forEach((voc) {
      if (voc.vocable.toLowerCase().contains(filter.toLowerCase())) {
        localResults.add(voc);
      }
    });

    // remove all vocables in the global list that are already in the local one
    localResults.forEach((localVoc) =>
        allVocables.removeWhere((globalVoc) => globalVoc.id == localVoc.id)
    );
    // filter remaining vocables in the global list
    List<Vocable> globalResults = [];
    allVocables.forEach((voc) {
      if (voc.vocable.toLowerCase().contains(filter.toLowerCase())) {
        globalResults.add(voc);
      }
    });

    _filteredVocables = List.of({...localResults, ...globalResults});
    _searchResults = _findDuplicatesAndConvert(_filteredVocables, toPackages: true);
    notifyListeners();
  }

  /// Helper function for finding [Vocable] duplicates, converting them to
  /// [SearchResult] and grouping them to [SearchResultPackage], which is
  /// used by [VocableSearchScreen] for displaying.
  /// Returns a [List] of [SearchResultItem].
  /// Duplicated vocables have their [MediaType] set in the corresponding
  /// [SearchResult.mediaType], which is [Null] otherwise.
  /// Asserts that the vocable list is already sorted as specified
  List<SearchResultItem> _findDuplicatesAndConvert(List<Vocable> vocables, {bool toPackages=false}) {
    // Mapping the vocable list to the corresponding SearchResult list
    List<SearchResult> searchResultList = vocables.map(SearchResult.new).toList();

    // Result list of type [SearchResultPackage]
    List<SearchResultPackage> tmpList = [];

    // Optionally grouping the searchResults after lecture id and replacing the id
    // with the corresponding lecture name by a lookup in the list of local lectures.
    // Then possible vocable duplicates are determined and sorted and the mediaType is set correspondingly.
    if (toPackages) {
      final groupedByLectureId = groupBy(searchResultList, (dynamic searchResult) => (searchResult as SearchResult).vocable.lectureId);
      groupedByLectureId.forEach((key, groupedSearchResultList) {
        if (localLectures != null) {
          Lecture? lecture = localLectures!.firstWhereOrNull((lecture) => lecture.id == key);
          if (lecture != null) {
            Map<String, bool> hasDuplicates = _determineDuplicates(groupedSearchResultList);
            _sortDuplicates(hasDuplicates, groupedSearchResultList);
            tmpList.add(SearchResultPackage(lecture.lesson, groupedSearchResultList));
          }
        }
      });
    } else {
      Map<String, bool> hasDuplicates = _determineDuplicates(searchResultList);
      _sortDuplicates(hasDuplicates, searchResultList);
      tmpList.add(SearchResultPackage("", searchResultList));
    }

    // sorting grouped lists excluding first one
    List<SearchResultPackage> searchResultPackageList = [];
    // If a lecture is selected, show results from the selected lecture first
    if (currentSelection!.type == SelectionType.lecture && tmpList.length > 1 && currentSelection!.lesson == tmpList[0].lectureTitle) {
      searchResultPackageList.add(tmpList.removeAt(0));
    }
    tmpList.sort((lec1, lec2) => Utils.customCompareTo(lec1.lectureTitle, lec2.lectureTitle));
    searchResultPackageList.addAll(tmpList);

    // Flatten structure to be used in a single list view
    return searchResultPackageList.expand((item) {
      return [
        if (item.lectureTitle.isNotEmpty) ItemHeader(item.lectureTitle),
        ...item.children.map(ItemRow.new)
      ];
    }).toList();
  }

  /// Determines possible [Vocable] duplicates.
  /// Returns a [HashMap] of type [String] and [bool], populated with every entry in [searchResultList] with value [True] or [False]
  /// indicating whether there are duplicates or not.
  /// Furthermore, for duplicates in [searchResultList] its corresponding [mediaType] is set to its [Vocable.mediaType].
  Map<String, bool> _determineDuplicates(List<SearchResult> searchResultList) {
    // This map is used for determining duplicated vocables by iterating over the list and
    // saving the vocables in the map. If a vocable is already saved, then the value
    // is set to true to indicate that there are duplicates for this vocable,
    // which is saved as key.
    Map<String, bool> hasDuplicates = HashMap();

    searchResultList.forEach((searchResult) {
      if (hasDuplicates.containsKey(searchResult.vocable.vocable)) {
        hasDuplicates[searchResult.vocable.vocable] = true;
      } else {
        hasDuplicates.putIfAbsent(searchResult.vocable.vocable, () => false);
      }
    });
    searchResultList.forEach((searchResult) {
      if (hasDuplicates[searchResult.vocable.vocable]!) {
        searchResult.mediaType = searchResult.vocable.mediaType;
      }
    });

    return hasDuplicates;
  }

  /// Sort duplicates by their mediaType
  /// For each duplicate group, extract the corresponding sublist, sort them, and replace the original with the sorted one.
  /// Returns [Void]; Manipulates the reference of [searchResultList].
  void _sortDuplicates(Map<String, bool> hasDuplicates, List<SearchResult> searchResultList) {
    // sort duplicates by their mediaType
    // for each duplicate group, extract the corresponding sublist, sort them, and replace the original with the sorted one
    // first remove non duplicates from duplicate-map
    hasDuplicates.removeWhere((key, value) => value == false);
    hasDuplicates.forEach((key, value) {
      // extract duplicate sublist
      int firstIndex = searchResultList.indexOf(searchResultList.firstWhere((element) => element.vocable.vocable == key));
      int lastIndex = searchResultList.indexOf(searchResultList.lastWhere((element) => element.vocable.vocable == key)) + 1;
      List<SearchResult> sublist = searchResultList.sublist(firstIndex, lastIndex);
      // sort
      sublist.sort((a,b) {
        // sort only searchResults with same vocable and not-null mediaType
        if (a.mediaType != null && b.mediaType != null && a.vocable.vocable == b.vocable.vocable) {
          // convert to MediaType and sort by sort-table of MediaType
          MediaType typeA = MediaType.fromString(a.mediaType!);
          MediaType typeB = MediaType.fromString(b.mediaType!);
          return typeA.compareTo(typeB);
        } else {
          return 0;
        }
      });
      // replace original duplicate-sublist with the sorted one
      searchResultList.replaceRange(firstIndex, lastIndex, sublist);
    });
  }
}
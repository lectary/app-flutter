import 'dart:async';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/screens/lectures/main_screen.dart';
import 'package:lectary/utils/utils.dart';


/// ViewModel for handling state of the carousel
/// uses [ChangeNotifier] for propagating changes to UI components
class CarouselViewModel with ChangeNotifier {
  final LectureRepository _lectureRepository;

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

  String _selectionTitle = "";
  String get selectionTitle => _selectionTitle;

  /// used in the carousel for keeping track of current item
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
  Future<void> loadAllVocables() async {
    _currentVocables = await _lectureRepository.findAllVocables();
    _currentItemIndex = 0;
    _selectionTitle = "Alle Vokabel";
    notifyListeners();
  }

  /// Loads all persisted [Vocable] from the passed [Lecture] and notifies listeners
  /// Sets [_currentMediaItems], [_selectionTitle] and [selectionDidUpdate] appropriate and resets
  /// [_currentItemIndex] back to 0.
  Future<void> loadVocablesOfLecture(Lecture lecture) async {
    _currentVocables = await _lectureRepository.findVocablesByLectureId(lecture.id);
    _currentItemIndex = 0;
    _selectionTitle = lecture.lesson;
    notifyListeners();
  }

  /// Loads all persisted [Vocable] from the passed [LecturePackage] and notifies listeners
  /// Sets [_currentMediaItems], [_selectionTitle] and [selectionDidUpdate] appropriate and resets
  /// [_currentItemIndex] back to 0.
  Future<void> loadVocablesOfPackage(LecturePackage pack) async {
    _currentVocables = await _lectureRepository.findVocablesByLecturePack(pack.title);
    _currentItemIndex = 0;
    _selectionTitle = pack.title;
    notifyListeners();
  }
}
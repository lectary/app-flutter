import 'dart:async';

import 'package:floor/floor.dart';
import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/models/media_item.dart';
import 'package:lectary/models/media_type_enum.dart';
import 'package:lectary/screens/lectures/main_screen.dart';
import 'package:lectary/utils/utils.dart';

/// ViewModel for handling state of the carousel
/// uses [ChangeNotifier] for propagating changes to UI components
class CarouselViewModel with ChangeNotifier {
  final LectureRepository _lectureRepository;

  /// used for indicating lecture selection switch to rebuild carousel
  bool selectionDidUpdate = false;

  List<Vocable> _currentVocables = List();
  List<Vocable> get currentVocables => _currentVocables;
  List<MediaItem> _currentMediaItems = List();
  List<MediaItem> get currentMediaItems => _currentMediaItems;

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
      _currentMediaItems.clear();
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
    List<Vocable> allVocables = await _lectureRepository.findAllVocables();
    _currentMediaItems = _transformVocablesToMediaItems(allVocables);
    _currentItemIndex = 0;
    _selectionTitle = "Alle Vokabel";
    selectionDidUpdate = true;
    notifyListeners();
  }

  /// Loads all persisted [Vocable] from the passed [Lecture] and notifies listeners
  /// Sets [_currentMediaItems], [_selectionTitle] and [selectionDidUpdate] appropriate and resets
  /// [_currentItemIndex] back to 0.
  Future<void> loadVocablesOfLecture(Lecture lecture) async {
    List<Vocable> vocables = await _lectureRepository.findVocablesByLectureId(lecture.id);
    _currentMediaItems = _transformVocablesToMediaItems(vocables);
    _currentItemIndex = 0;
    _selectionTitle = lecture.lesson;
    selectionDidUpdate = true;
    notifyListeners();
  }

  /// Loads all persisted [Vocable] from the passed [LecturePackage] and notifies listeners
  /// Sets [_currentMediaItems], [_selectionTitle] and [selectionDidUpdate] appropriate and resets
  /// [_currentItemIndex] back to 0.
  Future<void> loadVocablesOfPackage(LecturePackage pack) async {
    List<Vocable> vocables = await _lectureRepository.findVocablesByLecturePack(pack.title);
    _currentMediaItems = _transformVocablesToMediaItems(vocables);
    _currentItemIndex = 0;
    _selectionTitle = pack.title;
    selectionDidUpdate = true;
    notifyListeners();
  }

  /// Converts a list of [Vocable] into a list of [MediaItem] by the type of the vocable's [MediaType]
  /// Returns a list of [MediaItem]
  List<MediaItem> _transformVocablesToMediaItems(List<Vocable> vocables) {
    return vocables.map((vocable) {
      switch (MediaType.fromString(vocable.mediaType)) {
        case MediaType.MP4:
          return VideoItem(
              text: vocable.vocable,
              media: vocable.media
          );
          break;
        case MediaType.PNG:
        case MediaType.JPG:
          return PictureItem(
              text: vocable.vocable,
              media: vocable.media
          );
          break;
        case MediaType.TXT:
          return TextItem(
              text: vocable.vocable,
              media: vocable.media
          );
          break;
      }
    }).toList();
  }
}
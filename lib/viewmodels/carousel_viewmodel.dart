import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/models/lecture_package.dart';
import 'package:lectary/models/media_item.dart';
import 'package:lectary/models/media_type_enum.dart';
import 'package:lectary/utils/utils.dart';

/// ViewModel for handling state of the carousel
/// uses [ChangeNotifier] for propagating changes to UI components
class CarouselViewModel with ChangeNotifier {
  final LectureRepository _lectureRepository;

  bool _lecturesAvailable = false;
  bool get lecturesAvailable => _lecturesAvailable;

  List<Vocable> _currentVocables = List();
  List<Vocable> get currentVocables => _currentVocables;
  List<MediaItem> _currentMediaItems = List();
  List<MediaItem> get currentMediaItems => _currentMediaItems;

  int _currentItemIndex = 0;
  int get currentItemIndex => _currentItemIndex;

  set currentItemIndex(int currentItemIndex) {
    _currentItemIndex = currentItemIndex;
    notifyListeners();
  }

  /// Constructor with passed in [LectureRepository]
  CarouselViewModel({@required lectureRepository})
      : _lectureRepository = lectureRepository;


  /// Auto updating [Stream] by the floor database, containing all local persisted [Lecture]
  /// grouped as [LecturePackage]
  Stream<List<LecturePackage>> loadLocalLecturesAsStream() {
    return _lectureRepository.watchAllLectures().map((list) {
      _lecturesAvailable = list.isEmpty ? false : true;
      notifyListeners();
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

  Future<void> loadAllVocables() async {
    //TODO implement
  }

  Future<void> loadVocablesOfLecture(Lecture lecture) async {
    List<Vocable> vocables = await _lectureRepository.findVocablesByLectureId(lecture.id);
    _currentVocables = vocables;

    List<MediaItem> mediaItems = vocables.map((vocable) {
      switch(MediaType.fromString(vocable.mediaType)) {
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
    _currentMediaItems = mediaItems;
    _lecturesAvailable = true;
    notifyListeners();
  }

  Future<void> loadVocablesOfPackage(LecturePackage pack) async {
    //TODO implement
  }
}
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lectary/data/db/entities/abstract.dart';
import 'package:lectary/data/db/entities/coding.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/models/lectary_overview.dart';
import 'package:lectary/models/lecture_package.dart';

import 'package:lectary/models/media_type_enum.dart';
import 'package:lectary/models/response_type.dart';
import 'package:lectary/utils/exceptions/abstract_exception.dart';
import 'package:lectary/utils/exceptions/coding_exception.dart';
import 'package:lectary/utils/exceptions/no_internet_exception.dart';
import 'package:lectary/utils/utils.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:path_provider/path_provider.dart';

/// ViewModel containing data and methods for the lecture management screen and the drawer
/// uses [ChangeNotifier] for propagating changes to UI components
class LectureViewModel with ChangeNotifier {
  final LectureRepository _lectureRepository;
  late SettingViewModel _settingViewModel;

  /// Updates the local reference to [SettingViewModel].
  void updateSettings(SettingViewModel settingViewModel) {
    _settingViewModel = settingViewModel;
    notifyListeners();
    log("updated settings reference in lectureViewModel");
  }

  /// represents the loading status of fetching available lectures via [Response]
  Response _availableLectureStatus = Response.completed();
  Response get availableLectureStatus => _availableLectureStatus;

  bool _offlineMode = false;
  bool get offlineMode => _offlineMode;

  /// contains all [LecturePackage] that are available (persisted and remote ones)
  List<LecturePackage> _availableLectures = [];
  /// contains all filtered [LecturePackage] by reference from [_availableLectures]
  List<LecturePackage> _filteredLectures = [];
  List<LecturePackage> get availableLectures => _filteredLectures;

  String? _currentFilter;

  /// contains all persisted [Vocable]
  List<Vocable> _currentVocables = [];
  List<Vocable> get currentVocables => _currentVocables;

  /// contains all available (local and remote) [Coding]
  List<Coding> _availableCodings = [];

  /// Constructor with passed in [LectureRepository]
  LectureViewModel({required lectureRepository})
      : _lectureRepository = lectureRepository;

  void resetCurrentFilter() {
    _currentFilter = "";
  }

  /// Loads all available local and remote api-data, i.e. [Lecture], [Abstract], [Coding]
  /// Returns a [Future] and indicates its loading status via a separate variable [_availableLectureStatus] of type [Response]
  Future<void> loadLectaryData() async {
    _availableLectureStatus = Response.loading("loading data from server");
    notifyListeners();

    try {
      LectaryData lectaryData;
      // load local persisted data
      List<Lecture> localLectures = await _lectureRepository.loadLecturesLocal();
      List<Abstract> localAbstracts = await _lectureRepository.findAllAbstracts();
      List<Coding> localCodings = await _lectureRepository.findAllCodings();

      List<Lecture> mergedLectureList;
      List<Abstract> mergedAbstracts;

      try {
        // load remote api data
        lectaryData = await _lectureRepository.loadLectaryData();
        // merge and check status of lectures
        mergedLectureList = _mergeLectureLists(localLectures, lectaryData.lessons);
        // merge, check status and progress abstracts
        mergedAbstracts = mergeAndCheckAbstracts(localAbstracts, lectaryData.abstracts);
        await _progressAbstracts(mergedAbstracts);
        // merge, check status and progress codings
        List<Coding> mergedCodings = mergeAndCheckCodings(localCodings, lectaryData.codings);
        await _progressCodings(mergedCodings);
        _availableCodings = mergedCodings;
        log("loaded codings");
        _offlineMode = false;
      } on NoInternetException {
        log("no internet connection");
        mergedLectureList = localLectures;
        mergedLectureList.forEach((lecture) => lecture.lectureStatus = LectureStatus.persisted);
        mergedAbstracts = localAbstracts;
        _availableCodings = localCodings;
        _offlineMode = true;
      }

      // Sorting
      // 1) sort lessons with SORT-meta info by SORT
      List<Lecture> lecturesWithSortMeta = mergedLectureList.where((lecture) => lecture.sort != null).toList();
      lecturesWithSortMeta.sort((l1, l2) => l1.sort!.compareTo(l2.sort!));
      // 2) sort lessons without SORT-meta info lexicographic by lesson
      List<Lecture> lecturesWithoutSortMeta = mergedLectureList.where((lecture) => lecture.sort == null).toList();
      lecturesWithoutSortMeta.sort((l1, l2) => Utils.customCompareTo(l1.lesson, l2.lesson));
      // merge both sorted lists and group by lecture pack
      List<Lecture> allLectures = lecturesWithSortMeta;
      allLectures.addAll(lecturesWithoutSortMeta);
      List<LecturePackage> groupedLectureList = Utils.groupLecturesByPack(allLectures);
      // 3) sort lexicographic by packs
      groupedLectureList.sort((p1, p2) => Utils.customCompareTo(p1.title, p2.title));

      _availableLectures = groupedLectureList;
      if (_currentFilter != null && _currentFilter!.isNotEmpty) {
        filterLectureList(_currentFilter!);
      } else {
        _filteredLectures = _availableLectures; // assignment by reference
      }
      log("loaded lectures");

      // load again all persisted abstracts and add them to the corresponding packs
      List<Abstract> availableAbstracts = await _lectureRepository.findAllAbstracts();
      availableAbstracts.forEach((abstract) {
        groupedLectureList.firstWhereOrNull((pack) => pack.title == abstract.pack)?.abstract = abstract.text;
      });
      log("loaded abstracts");

      _availableLectureStatus = Response.completed();
      notifyListeners();
    } catch(e) {
      _availableLectureStatus = Response.error(e.toString());
      notifyListeners();
    }
  }

  /// Method to report errors back to the lectary server.
  static void reportErrorToLectaryServer(String errorMessage) {
    final format = DateFormat('yyyy-MM-dd-HH_mm');
    final timestamp = format.format(DateTime.now());
    LectureRepository.reportErrorToServer(timestamp, errorMessage);
  }


  ////////////////////////////////////////////////////////////////////////////////////////////////
  ////// LECTURES ////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// Merges the remote and local lecture list
  /// Returns a list of [Lecture] containing all locally persisted and remote available lectures with the corresponding [LectureStatus]
  List<Lecture> _mergeLectureLists(List<Lecture> localList, List<Lecture> remoteList) {
    List<Lecture> resultList = [];

    // comparing local with remote list and adding all local persisted lectures to the result list and checking if updates are available (i.e. identical lecture with never date)
    localList.forEach((local) {
      remoteList.forEach((remote) {
        if (local.pack == remote.pack && local.lesson == remote.lesson) {
          if (DateTime.parse(local.date).isBefore(DateTime.parse(remote.date))) {
            local.lectureStatus = LectureStatus.updateAvailable;
            local.fileNameUpdate = remote.fileName;
            resultList.add(local);
          } else {
            local.lectureStatus = LectureStatus.persisted;
            resultList.add(local);
          }
        }
      });
    });

    // check if any local lectures are outdated (i.e. not available remotely anymore)
    localList.forEach((e1) {
      if (remoteList.any((e2) => e1.pack == e2.pack && e1.lesson == e2.lesson) == false) {
        e1.lectureStatus = LectureStatus.removed;
        resultList.add(e1);
      }
    });

    // add all remaining and not persisted lectures available remotely
    remoteList.forEach((e1) {
      if (localList.any((e2) => e1.pack == e2.pack && e1.lesson == e2.lesson) == false) {
        e1.lectureStatus = LectureStatus.notPersisted;
        resultList.add(e1);
      }
    });

    resultList = resultList.where((lecture) => lecture.langMedia == _settingViewModel.settingLearningLanguage).toList();

    return resultList;
  }

  /// Download and persist a lecture
  /// Returns [Response] as a Future, with the corresponding [Status] set, reflecting success or failure
  Future<Response> downloadAndSaveLecture(Lecture lecture) async {
    log("downloading lecture: ${lecture.toString()}");

    // retrieve index of pack and index of lecture of the lecture-parameter to change LectureStatus
    int indexPack = _availableLectures.indexWhere((lecturePack) => lecturePack.title == lecture.pack);
    int indexLecture = _availableLectures[indexPack].children.indexWhere((_lecture) => _lecture.lesson == lecture.lesson);

    // update LectureStatus and notify listeners for updating UI
    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.downloading;
    notifyListeners();

    // Check if additional coding files are needed
    List<CodingEntry>? codingEntries;
    try {
      codingEntries = await _checkNeedForCoding(lecture);
    } catch(e) {
      log("downloading coding failed: ${e.toString()}");
    }

    try {
      File lectureFile = await _lectureRepository.downloadLecture(lecture); // download lecture and save zip temporary as file
      List<Vocable> vocables = await _extractAndSaveZipFile(lectureFile); // extract zip and save content
      int newId = await _lectureRepository.insertLecture(lecture); // persist lecture and retrieve autoGenerated id
      vocables.forEach((vocable) {
        vocable.lectureId = newId;
        String deAsciified = codingEntries == null
            ? Utils.deAsciify(vocable.vocable)
            : Utils.deAsciify(vocable.vocable, codingEntries: codingEntries);
        vocable.vocable = deAsciified;
        vocable.vocableSort = Utils.replaceForSort(deAsciified);
        // inherit audio metaDatum from lecture if requirements are met
        if (vocable.audio == null && MediaType.fromString(vocable.mediaType) == MediaType.MP4 && lecture.audio != null) {
          vocable.audio = lecture.audio;
        }
      }); // set id in every vocable and deAsciify
      await _lectureRepository.insertVocables(vocables); // save the vocables in the database

      _availableLectures[indexPack].children[indexLecture].id = newId; // set newId in the lecture list for later usage like updating or deleting
      _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.persisted;
      notifyListeners();

      // set setting of "freshAppInstallation" to false
      if (_settingViewModel.settingAppFreshInstalled) {
        _settingViewModel.setSettingAppFreshInstalled(false);
      }

      return Response.completed();
    } catch(e) {
      log("downloading lecture failed: ${e.toString()}");
      _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.notPersisted;
      notifyListeners();

      return Response.error(e.toString());
    }
  }

  /// Updates a lecture
  /// The lecture-update is first downloaded and extracted for validation, then the old lecture is deleted
  /// and the new lecture saved.
  /// Returns [Response] as a Future, with the corresponding [Status] set, reflecting success or failure
  Future<Response> updateLecture(Lecture lecture) async {
    log("updating lecture: ${lecture.toString()}");

    // retrieve index of pack and index of lecture of the lecture-parameter to change LectureStatus
    int indexPack = _availableLectures.indexWhere((lecturePack) => lecturePack.title == lecture.pack);
    int indexLecture = _availableLectures[indexPack].children.indexWhere((_lecture) => _lecture.lesson == lecture.lesson);

    // update LectureStatus and notify listeners for updating UI
    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.downloading;
    notifyListeners();

    Lecture oldLecture = Lecture.clone(lecture);

    // updating object values for downloading and saving
    lecture.id = null;
    lecture.fileName = lecture.fileNameUpdate!;
    lecture.fileNameUpdate = null;
    String newDate = Utils.extractDateMetadatumFromFileName(lecture.fileName);
    lecture.date = newDate;

    // Check if additional coding files are needed
    List<CodingEntry>? codingEntries;
    try {
      codingEntries = await _checkNeedForCoding(lecture);
    } catch(e) {
      log("downloading coding failed: ${e.toString()}");
    }

    try {
      log("downloading new lecture: ${lecture.toString()}");
      File lectureFile = await _lectureRepository.downloadLecture(lecture); // download lecture and save zip temporary as file
      List<Vocable> vocables = await _extractAndSaveZipFile(lectureFile); // extract zip and save content

      // delete media files and database entries
      log("deleting old lecture: ${oldLecture.toString()}");
      await _deleteMediaFiles(oldLecture);
      await _lectureRepository.deleteVocablesByLectureId(oldLecture.id!);
      await _lectureRepository.deleteLecture(oldLecture);

      log("saving new lecture: ${lecture.toString()}");
      int newId = await _lectureRepository.insertLecture(lecture); // persist lecture and retrieve autoGenerated id
      vocables.forEach((element) {
        element.lectureId = newId;
        String deAsciified = Utils.deAsciify(element.vocable);
        codingEntries == null
            ? element.vocable = deAsciified
            : element.vocable = Utils.deAsciify(element.vocable, codingEntries: codingEntries);
        element.vocableSort = Utils.replaceForSort(deAsciified);
        //element.audio = Utils.extractAudioMetaInfoFromFilename() ??
      }); // set id in every vocable and deAsciify
      await _lectureRepository.insertVocables(vocables); // save the vocables in the database

      _availableLectures[indexPack].children[indexLecture].id = newId; // set newId in the lecture list for later usage like updating or deleting
      _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.persisted;
      notifyListeners();

      return Response.completed();
    } catch(e) {
      log("updating lecture failed: ${e.toString()}");
      // resetting object values
      lecture.id = oldLecture.id;
      lecture.fileName = oldLecture.fileName;
      lecture.fileNameUpdate = oldLecture.fileNameUpdate;
      lecture.date = oldLecture.date;

      _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.updateAvailable;
      notifyListeners();

      return Response.error(e.toString());
    }
  }

  /// Deletes a lecture
  /// All database entries and files from the lecture are removed from the device.
  /// returns [Response] as a Future, with the corresponding [Status] set, reflecting success or failure
  Future<Response> deleteLecture(Lecture lecture) async {
    log("deleting lecture: ${lecture.toString()}");

    // retrieve index of pack and index of lecture of the lecture-parameter to change LectureStatus
    int indexPack = _availableLectures.indexWhere((lecturePack) => lecturePack.title == lecture.pack);
    int indexLecture = _availableLectures[indexPack].children.indexWhere((_lecture) => _lecture.lesson == lecture.lesson);

    LectureStatus oldLectureStatus = _availableLectures[indexPack].children[indexLecture].lectureStatus;

    // update LectureStatus and notify listeners for updating UI
    _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.downloading;
    notifyListeners();

    // Check if coding needs to be deleted
    try {
      _checkDeletingOfCoding(lecture);
    } catch(e) {
      log("error when deleting coding: ${e.toString()}");
    }

    try {
      // delete media files and database entries
      await _deleteMediaFiles(lecture);
      await _lectureRepository.deleteVocablesByLectureId(lecture.id!);
      await _lectureRepository.deleteLecture(lecture);

      // check if removed lecture is still available remotely
      if (oldLectureStatus == LectureStatus.removed) {
        // remove lecture from lecture list as well from the filtered list if not available anymore remotely
        _availableLectures[indexPack].children.removeAt(indexLecture);
        if (_currentFilter != null && _currentFilter!.isNotEmpty) {
          int indexPackFilter = _filteredLectures.indexWhere((lecturePack) => lecturePack.title == lecture.pack);
          int indexLectureFilter = _filteredLectures[indexPackFilter].children.indexWhere((_lecture) => _lecture.lesson == lecture.lesson);
          _filteredLectures[indexPackFilter].children.removeAt(indexLectureFilter);
        }
      } else {
        _availableLectures[indexPack].children[indexLecture].lectureStatus = LectureStatus.notPersisted;
      }
      notifyListeners();

      return Response.completed();
    } catch(e) {
      log("deleting lecture failed: ${e.toString()}");
      return Response.error(e.toString());
    }
  }

  /// Deletes all lectures, vocables and corresponding media files
  /// Returns a [Future] of type [Void]
  Future<void> deleteAllLectures() async {
    log("querying all lectures");
    List<Lecture> lectures = await _lectureRepository.loadLecturesLocal();
    log("deleting all media files");
    await Future.forEach(lectures, (dynamic lecture) => _deleteMediaFiles(lecture));
    log("deleting database entries");
    await _lectureRepository.deleteAllVocables();
    await Future.forEach(lectures, (dynamic lecture) => _lectureRepository.deleteLecture(lecture));
    await _lectureRepository.deleteAllCodingEntries();
    await _lectureRepository.deleteAllCoding();
  }

  /// Deletes all lectures with a specific [Lecture.langMedia] and their vocables and corresponding media files
  /// Returns a [Future] of type [Void]
  Future<void> deleteAllLecturesFromLangMedia(String langMedia) async {
    log("deleting all lectures and their contents of language $langMedia");
    List<Lecture> lectures = await _lectureRepository.findAllLecturesWithLang(langMedia);
    log("deleting media files");
    await Future.forEach(lectures, (dynamic lecture) => _deleteMediaFiles(lecture));
    log("deleting database entries");
    await _lectureRepository.deleteAllVocablesByLangMedia(langMedia);
    await Future.forEach(lectures, (dynamic lecture) {
      // Check if coding needs to be deleted
      try {
        _checkDeletingOfCoding(lecture);
      } catch(e) {
        log("error when deleting coding: ${e.toString()}");
      }
      return _lectureRepository.deleteLecture(lecture);
    });
  }

  /// Deletes media files related to the lecture
  /// Returns a [Future] of type [Void]
  Future<void> _deleteMediaFiles(Lecture lecture) async {
    String dir = (await getApplicationDocumentsDirectory()).path;

    final dirName = lecture.fileName.split('.')[0];
    final lectureDir = Directory(dir + '/' + dirName);
    lectureDir.deleteSync(recursive: true);
  }

  /// Extracts and saves the content of a zip-file
  /// Returns a list of [Vocable], representing all vocables of the extracted zip-file
  Future<List<Vocable>> _extractAndSaveZipFile(File zipFile) async {
    // read zip file and decode archive
    var bytes = zipFile.readAsBytesSync();
    Archive archive = ZipDecoder().decodeBytes(bytes);

    // validate archive
    Utils.validateArchive(zipFile, archive);

    // get the path to the device's application directory
    String dir = (await getApplicationDocumentsDirectory()).path;

    List<Vocable> vocables = [];

    for (ArchiveFile file in archive) {
      if (!file.isFile) continue;

      // file.name holds archive name plus actual filename
      String filePath = '$dir/${file.name}';

      Vocable? newVocable = Vocable.fromFilePath(filePath);
      if (newVocable != null) vocables.add(newVocable);

      // saving media file locally
      File outFile = File(filePath);
      outFile = await outFile.create(recursive: true);
      await outFile.writeAsBytes(file.content);
    }

    return vocables;
  }

  /// Filters the [List] of available [Lecture] by a [String]
  /// Filters by pack and lesson of [Lecture]
  /// Creates a temporary list with the filtered elements as references to the original list elements of
  /// [_availableLectures] and assigns it by reference again to [_filteredLectures] and notifies listeners
  /// Operations on the original list [_availableLectures] will therefore also affect the corresponding elements in [_filteredLectures]
  void filterLectureList(String filter) {
    _currentFilter = filter;

    List<Lecture> tempListLectures = [];
    _availableLectures.forEach((pack) => pack.children.forEach((lecture) {
      if (lecture.pack.toLowerCase().contains(filter.toLowerCase()) ||
          lecture.lesson.toLowerCase().contains(filter.toLowerCase())) {
        tempListLectures.add(lecture);
      }
    }));
    List<LecturePackage> tempListPacks = Utils.groupLecturesByPack(tempListLectures);
    tempListPacks.forEach((pack) => pack.abstract = _availableLectures.firstWhere((element) => element.title == pack.title).abstract);
    _filteredLectures = tempListPacks;
    notifyListeners();
  }


  ////////////////////////////////////////////////////////////////////////////////////////////////
  ////// ABSTRACTS ///////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// Merges and validates the stati of two lists of [Abstract]
  /// Returns a list of [Abstract] with the corresponding [AbstractStatus]
  @visibleForTesting
  List<Abstract> mergeAndCheckAbstracts(List<Abstract> localList, List<Abstract> remoteList) {
    List<Abstract> resultList = [];

    // comparing local with remote list and adding all local persisted lectures to the result list and checking if updates are available (i.e. identical lecture with never date)
    localList.forEach((local) {
      remoteList.forEach((remote) {
        if (local.pack == remote.pack) {
          if (DateTime.parse(local.date).isBefore(DateTime.parse(remote.date))) {
            local.abstractStatus = AbstractStatus.updateAvailable;
            local.fileNameUpdate = remote.fileName;
            resultList.add(local);
          } else {
            local.abstractStatus = AbstractStatus.persisted;
            resultList.add(local);
          }
        }
      });
    });

    // check if any local lectures are outdated (i.e. not available remotely anymore)
    localList.forEach((e1) {
      if (remoteList.any((e2) => e1.pack == e2.pack) == false) {
        e1.abstractStatus = AbstractStatus.removed;
        resultList.add(e1);
      }
    });

    // add all remaining and not persisted lectures available remotely
    remoteList.forEach((remote) {
      if (localList.any((local) => remote.pack == local.pack) == false) {
        remote.abstractStatus = AbstractStatus.notPersisted;
        resultList.add(remote);
      }
    });

    return resultList;
  }

  /// Progresses a list of available [Abstract]
  /// Downloads, updates or deletes an [Abstract] corresponding to its [AbstractStatus]
  /// Returns a [Future] of type [Void]
  Future<void> _progressAbstracts(List<Abstract> mergedAbstracts) async {
    await Future.forEach(mergedAbstracts, (dynamic abstract) async {
      switch(abstract.abstractStatus) {
        case AbstractStatus.notPersisted:
          log("downloading new abstract");
          await _downloadAndSaveAbstract(abstract);
          break;
        case AbstractStatus.updateAvailable:
          log("updating abstract");
          await _updateAbstract(abstract);
          break;
        case AbstractStatus.removed:
          log("deleting abstract");
          await _deleteAbstract(abstract);
          break;
        case AbstractStatus.persisted:
        default:
          break;
      }
    });
  }

  /// Downloads and saves an [Abstract]
  /// Returns a [Future] of type [Void]
  /// Throws [AbstractException] on error
  Future<void> _downloadAndSaveAbstract(Abstract abstract) async {
    try {
      File file = await _lectureRepository.downloadAbstract(abstract);
      String text = file.readAsStringSync();
      text = text.replaceAll("\n", "");
      abstract.text = text;
      await _lectureRepository.insertAbstract(abstract);
    } catch(e) {
      log("Downloading abstract: $abstract failed: ${e.toString()}");
    }
  }

  /// Updates an [Abstract]
  /// Returns a [Future] of type [Void]
  /// Throws [AbstractException] on error
  Future<void> _updateAbstract(Abstract abstract) async {
    try {
      abstract.fileName = abstract.fileNameUpdate!;
      abstract.fileNameUpdate = null;
      String newDate = Utils.extractDateMetadatumFromFileName(abstract.fileName);
      abstract.date = newDate;
      File file = await _lectureRepository.downloadAbstract(abstract);
      String text = file.readAsStringSync();
      text = text.replaceAll("\n", "");
      abstract.text = text;
      await _lectureRepository.updateAbstract(abstract);
    } catch(e) {
      log("Updating abstract: $abstract failed: ${abstract.toString()}");
    }
  }

  /// Deletes an [Abstract]
  /// Returns a [Future] of type [Void]
  /// Throws [AbstractException] on error
  Future<void> _deleteAbstract(Abstract abstract) async {
    try {
      await _lectureRepository.deleteAbstract(abstract);
    } catch(e) {
      log("Deleting abstract: $abstract failed: ${e.toString()}");
    }
  }


  ////////////////////////////////////////////////////////////////////////////////////////////////
  ////// CODINGS /////////////////////////////////////////////////////////////////////////////////
  ////////////////////////////////////////////////////////////////////////////////////////////////

  /// Merges and validates the stati of two lists of [Coding]
  /// Returns a list of [Coding] with the corresponding [CodingStatus]
  @visibleForTesting
  List<Coding> mergeAndCheckCodings(List<Coding> localList, List<Coding> remoteList) {
    List<Coding> resultList = [];

    // comparing local with remote list and adding all local persisted lectures to the result list and checking if updates are available (i.e. identical lecture with never date)
    localList.forEach((local) {
      remoteList.forEach((remote) {
        if (local.lang == remote.lang) {
          if (DateTime.parse(local.date).isBefore(DateTime.parse(remote.date))) {
            local.codingStatus = CodingStatus.updateAvailable;
            local.fileNameUpdate = remote.fileName;
            resultList.add(local);
          } else {
            local.codingStatus = CodingStatus.persisted;
            resultList.add(local);
          }
        }
      });
    });

    // check if any local lectures are outdated (i.e. not available remotely anymore)
    localList.forEach((e1) {
      if (remoteList.any((e2) => e1.lang == e2.lang) == false) {
        e1.codingStatus = CodingStatus.removed;
        resultList.add(e1);
      }
    });

    // add all remaining and not persisted lectures available remotely
    remoteList.forEach((remote) {
      if (localList.any((local) => remote.lang == local.lang) == false) {
        remote.codingStatus = CodingStatus.notPersisted;
        resultList.add(remote);
      }
    });

    return resultList;
  }

  /// Progresses a list of  [Coding]
  /// Updates or removes a [Coding] corresponding to its [CodingStatus]
  /// Returns a [Future] of type [Void]
  Future<void> _progressCodings(List<Coding> mergedCodings) async {
    await Future.forEach(mergedCodings, (dynamic coding) async {
      switch(coding.codingStatus) {
        case CodingStatus.updateAvailable:
          await updateCoding(coding);
          break;
        case CodingStatus.removed:
          await _deleteCoding(coding);
          break;
        default:
          break;
      }
    });
  }

  /// Checks if a [Lecture] needs an additional [Coding] and downloads it
  /// Returns a [Future] of type [Void]
  Future<List<CodingEntry>?> _checkNeedForCoding(Lecture lecture) async {
    if (lecture.langVocable == "DE" || lecture.langVocable == "EN") {
      return null;
    }
    log("additional coding needed for language: ${lecture.langVocable}");

    Coding? coding = _availableCodings.firstWhereOrNull((element) => element.lang == lecture.langVocable);
    if (coding != null) {
      if (coding.codingStatus == CodingStatus.notPersisted) {
        log("coding needed for language: ${lecture.langVocable} is not already persisted...downloading...");
        List<CodingEntry>? codingEntries = await _downloadAndSaveCoding(coding);
        return codingEntries;
      } else if (coding.codingStatus == CodingStatus.persisted) {
        log("coding needed for language: ${lecture.langVocable} is already persisted...querying...");
        List<CodingEntry> codingEntries = await _lectureRepository.findAllCodingEntriesByCodingId(coding.id!);
        return codingEntries;
      } else
        return null;
    } else {
      log("coding needed for language: ${lecture.langVocable} is not available");
      return null;
    }
  }

  /// Checks if a [Coding] is still needed after deleting a [Lecture] and deletes it
  void _checkDeletingOfCoding(Lecture lecture) {
    if (lecture.langVocable == "DE" || lecture.langVocable == "EN") {
      return;
    }
    List<Lecture> lecturesThatNeedCoding = [];
    // retrieve all persisted lectures with the corresponding language besides the passed one
    _availableLectures.forEach((pack) =>
        lecturesThatNeedCoding.addAll(pack.children.where((lec) => lec.id != lecture.id && lec.lectureStatus == LectureStatus.persisted && lec.langVocable == lecture.langVocable)));
    if (lecturesThatNeedCoding.isEmpty) {
      log("coding no longer needed");
      _deleteCoding(_availableCodings.firstWhere((element) => element.lang == lecture.langVocable));
    }
  }

  /// Downloads and saves a [Coding]
  /// Returns a [Future] of type [Void]
  /// Throws [CodingException] on error
  Future<List<CodingEntry>?> _downloadAndSaveCoding(Coding coding) async {
    log("downloading coding: $coding");
    try{
      File file = await _lectureRepository.downloadCoding(coding);
      List<CodingEntry> codingEntries = extractCodingEntries(file);
      int newId = await _lectureRepository.insertCoding(coding);
      codingEntries.forEach((entry) => entry.codingId = newId);
      await _lectureRepository.insertCodingEntries(codingEntries);
      _availableCodings.firstWhere((element) => element.lang == coding.lang).id = newId;
      _availableCodings.firstWhere((element) => element.lang == coding.lang).codingStatus = CodingStatus.persisted;
      return codingEntries;
    } catch(e) {
      log("Downloading coding: $coding failed: ${e.toString()}");
      return null;
    }
  }

  /// Updates a [Coding]
  /// Returns a [Future] of type [Void]
  /// Throws [CodingException] on error
  @visibleForTesting
  Future<void> updateCoding(Coding coding) async {
    log("updating coding: $coding");
    List<CodingEntry>? newCodingEntries;
    try {
      await _lectureRepository.deleteCodingEntriesByCodingId(coding.id!);
      // update coding infos
      coding.fileName = coding.fileNameUpdate!;
      coding.fileNameUpdate = null;
      String newDate = Utils.extractDateMetadatumFromFileName(coding.fileName);
      coding.date = newDate;
      // download new coding and extract content
      File file = await _lectureRepository.downloadCoding(coding);
      newCodingEntries = extractCodingEntries(file);
      await _lectureRepository.updateCoding(coding);
      newCodingEntries.forEach((entry) => entry.codingId = coding.id!);
      await _lectureRepository.insertCodingEntries(newCodingEntries);
      // set coding status in corresponding coding
      Coding? cod = _availableCodings.firstWhereOrNull((element) => element.lang == coding.lang);
      if (cod != null) {
        cod.codingStatus = CodingStatus.persisted;
      }
    } catch(e) {
      log("Updating coding: $coding failed: ${e.toString()}");
    }

    // update all vocables
    try {
      // query all vocables from lectures that use the coding language
      List<Lecture> lecturesWithCoding = await _lectureRepository.findAllLecturesWithLang(coding.lang);
      List<List<Vocable>> results = await Future.wait(
          lecturesWithCoding.map((lecture) async =>
          await _lectureRepository.findVocablesByLectureId(lecture.id!)
          )
      );
      // deAsciify all found vocables and update db
      List<Vocable> vocablesToUpdate = [];
      results.forEach((element) => vocablesToUpdate.addAll(element));
      vocablesToUpdate.forEach((voc) => voc.vocable = Utils.deAsciify(voc.vocable, codingEntries: newCodingEntries));
      await _lectureRepository.updateVocables(vocablesToUpdate);
    } catch(e) {
      log("Failed to update vocables with coding ${coding.toString()}");
    }
  }

  /// Deletes a [Coding]
  /// Returns a [Future] of type [Void]
  /// Throws [CodingException] on error
  Future<void> _deleteCoding(Coding coding) async {
    log("deleting coding: $coding");
    try {
      await _lectureRepository.deleteCodingEntriesByCodingId(coding.id!);
      await _lectureRepository.deleteCoding(coding);
      _availableCodings.firstWhere((element) => element.lang == coding.lang).codingStatus = CodingStatus.notPersisted;
    } catch(e) {
      log("Deleting coding: $coding failed: ${e.toString()}");
    }
  }

  /// Extracts the content of a json [File] containing the list of [CodingEntry]
  /// Returns a [List] of [CodingEntry] on success or [Null] on error
  @visibleForTesting
  List<CodingEntry> extractCodingEntries(File jsonFile) {
    // read and decode json file
    String jsonString = jsonFile.readAsStringSync();
    try {
      List<dynamic> jsonData = json.decode(jsonString);

      List<CodingEntry> codingEntries = jsonData
          .map((entry) =>
          CodingEntry(char: entry["char"], ascii: entry["asciify"]))
          .toList();

      return codingEntries;
    } catch(e) {
      throw CodingException("extracting coding entries from json failed: ${e.toString()}");
    }
  }
}
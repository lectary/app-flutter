import 'package:lectary/data/db/entities/abstract.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/viewmodels/lecture_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:test/test.dart';

import '../shared_mocks.mocks.dart';

// class MockLectureRepository extends Mock implements LectureRepository {}
@GenerateMocks([LectureRepository])
void main() {
  group('Testing status handling of "mergeAndCheckAbstracts" |', () {
    LectureViewModel lectureViewModel = LectureViewModel(lectureRepository: MockLectureRepository());
    test('should set status to "notPersisted"', () {
      List<Abstract> localList = [];
      List<Abstract> remoteList = List.of({
        Abstract(
            fileName: "ABSTRACT--Geb_aerden__lernen---DATE--2020-06-21.txt",
            pack: "Gebärden lernen",
            text: "",
            date: "2020-06-21")
      });

      List<Abstract> mergedAbstracts = lectureViewModel.mergeAndCheckAbstracts(localList, remoteList);
      expect(mergedAbstracts[0].abstractStatus, AbstractStatus.notPersisted);
    });
    test('should set status to "updateAvailable"', () {
      List<Abstract> localList = List.of({
        Abstract(
            fileName: "ABSTRACT--Geb_aerden__lernen---DATE--2020-06-21.txt",
            pack: "Gebärden lernen",
            text: "",
            date: "2020-06-20")
      });
      List<Abstract> remoteList = List.of({
        Abstract(
            fileName: "ABSTRACT--Geb_aerden__lernen---DATE--2020-06-21.txt",
            pack: "Gebärden lernen",
            text: "",
            date: "2020-06-21")
      });

      List<Abstract> mergedAbstracts = lectureViewModel.mergeAndCheckAbstracts(localList, remoteList);
      expect(mergedAbstracts[0].abstractStatus, AbstractStatus.updateAvailable);
    });
    test('should set status to "removed"', () {
      List<Abstract> localList = List.of({
        Abstract(
            fileName: "ABSTRACT--Geb_aerden__lernen---DATE--2020-06-21.txt",
            pack: "Gebärden lernen",
            text: "",
            date: "2020-06-21")
      });
      List<Abstract> remoteList = [];

      List<Abstract> mergedAbstracts = lectureViewModel.mergeAndCheckAbstracts(localList, remoteList);
      expect(mergedAbstracts[0].abstractStatus, AbstractStatus.removed);
    });
  });
}

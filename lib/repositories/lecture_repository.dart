import 'package:lectary/models/lecture.dart';
import 'package:lectary/services/lectary_api.dart';

class LectureRepository {
  LectaryApi _lectaryApi = LectaryApi();

  Future<List<Lecture>> loadLecturesRemote() async {
    try {
      List<Lecture> lectureList = await _lectaryApi.fetchLectures();
      return lectureList;
    } catch(e) {
      return null;
    }
  }

  Future<List<Lecture>> loadLecturesLocal() async {
    // TODO add persistence layer

    return List.of({
      Lecture(
        fileName: "PACK--Alpen__Adria__Universit_aet---LESSON--AAU__Lektion__4---LANG--OGS-DE---SORT--104---DATE--2019-04-29.zip",
        pack: "Alpen__Adria__Universit_aet",
        lesson: "AAU__Lektion__4",
        date: DateTime.parse("2019-04-29"),
      ),
      Lecture(
        fileName: "PACK--Alpen__Adria__Universit_aet---LESSON--AAU__Lektion__5---LANG--OGS-DE---SORT--105---DATE--2019-04-29.zip",
        pack: "Alpen__Adria__Universit_aet",
        lesson: "AAU__Lektion__5",
        date: DateTime.parse("2019-04-30"),
      ),
      Lecture(
        fileName: "PACK--Alpen__Adria__Universit_aet---LESSON--TEST---LANG--OGS-DE---SORT--105---DATE--2019-04-29.zip",
        pack: "Alpen__Adria__Universit_aet",
        lesson: "TEST",
        date: DateTime.parse("2019-04-29"),
      ),
    });
  }
}
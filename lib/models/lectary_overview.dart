import 'dart:developer';
import 'package:lectary/data/db/entities/abstract.dart';
import 'package:lectary/data/db/entities/coding.dart';
import 'package:lectary/data/db/entities/lecture.dart';


class LectaryData {
  List<Lecture> lessons;
  List<Abstract> abstracts;
  List<Coding> codings;

  LectaryData({this.lessons, this.abstracts, this.codings});

  factory LectaryData.fromJson(Map<String, dynamic> json) {
    // extract json list first to avoid some exceptions
    List<dynamic> jsonLessons = json['lesson'];
    List<Lecture> lessons = jsonLessons
        .map((element) => Lecture.fromJson(element))
        .where((element) => element != null)
        .toList();
    List<dynamic> jsonAbstracts = json['abstract'];
    List<Abstract> abstracts = jsonAbstracts
        .map((element) => Abstract.fromJson(element))
        .where((element) => element != null)
        .toList();
    List<dynamic> jsonCodings = json['asciify'];
    List<Coding> codings = jsonCodings
        .map((element) => Coding.fromJson(element))
        .where((element) => element != null)
        .toList();

    log("extracted LectaryData from json");

    return LectaryData(
      lessons: lessons,
      abstracts: abstracts,
      codings: codings,
    );
  }

  @override
  String toString() {
    return 'LectaryOverview{lessons: $lessons, abstracts: $abstracts, codings: $codings}';
  }
}

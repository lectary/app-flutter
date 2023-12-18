import 'dart:developer';

import 'package:lectary/data/db/entities/abstract.dart';
import 'package:lectary/data/db/entities/coding.dart';
import 'package:lectary/data/db/entities/lecture.dart';

class LectaryData {
  List<Lecture> lessons;
  List<Abstract> abstracts;
  List<Coding> codings;

  LectaryData({
    required this.lessons,
    required this.abstracts,
    required this.codings,
  });

  factory LectaryData.fromJson(Map<String, dynamic> json) {
    // extract json list first to avoid some exceptions
    List<dynamic> jsonLessons = json['lesson'];
    List<Lecture> lessons = jsonLessons
        .map((element) => Lecture.fromJson(element))
        .where((element) => element != null)
        .toList()
        .cast<Lecture>();
    List<dynamic> jsonAbstracts = json['abstract'];
    List<Abstract> abstracts = jsonAbstracts
        .map((element) => Abstract.fromJson(element))
        .where((element) => element != null)
        .toList()
        .cast<Abstract>();
    List<dynamic> jsonCodings = json['asciify'];
    List<Coding> codings = jsonCodings
        .map((element) => Coding.fromJson(element))
        .where((element) => element != null)
        .toList()
        .cast<Coding>();

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

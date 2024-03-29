import 'dart:developer';

import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/utils/utils.dart';
import 'package:test/test.dart';

void main() {

  group('Testing distribution of chooseRandomVocable | ', () {
      test('List with one standard vocable with index 0', () {
      List<Vocable> listOf6WithOneStandardVocable = List.of({
        Vocable(id: 1, lectureId: 1, vocable: "voc1", vocableProgress: 0, vocableSort: "", media: "", mediaType: ""),
        Vocable(id: 2, lectureId: 1, vocable: "voc2", vocableProgress: 2, vocableSort: "", media: "", mediaType: ""),
        Vocable(id: 3, lectureId: 1, vocable: "voc3", vocableProgress: 2, vocableSort: "", media: "", mediaType: ""),
        Vocable(id: 4, lectureId: 1, vocable: "voc4", vocableProgress: 2, vocableSort: "", media: "", mediaType: ""),
        Vocable(id: 5, lectureId: 1, vocable: "voc5", vocableProgress: 2, vocableSort: "", media: "", mediaType: ""),
        Vocable(id: 6, lectureId: 1, vocable: "voc6", vocableProgress: 2, vocableSort: "", media: "", mediaType: ""),
      });

      Map resultMap1 = {};
      for (int i=0; i < 1000; i++) {
        int index = Utils.chooseRandomVocable(true, listOf6WithOneStandardVocable);
        if (resultMap1.containsKey(index)) {
          resultMap1.update(index, (value) => value + 1);
        } else {
          resultMap1.putIfAbsent(index, () => 1);
        }
      }
      log("Selection rate when vocable progress is enabled: \n$resultMap1");

      // Computing the average value
      int? specialValue = resultMap1.remove(0);
      double average = resultMap1.keys.map((key) {
        return resultMap1[key];
      }).toList().reduce((a, b) => a + b) / resultMap1.length;
      log("Special selection rate: $specialValue");
      log("Average selection rate: $average");

      expect(specialValue, greaterThan(average * 2));

      Map resultMap2 = {};
      for (int i=0; i < 1000; i++) {
        int index = Utils.chooseRandomVocable(false, listOf6WithOneStandardVocable);
        if (resultMap2.containsKey(index)) {
          resultMap2.update(index, (value) => value + 1);
        } else {
          resultMap2.putIfAbsent(index, () => 1);
        }
      }
      log("Selection rate when vocable progress is disabled: \n$resultMap2");

    });



    test('List with one very good vocable with index 5', ()
    {
      List<Vocable> listOf6WithOneReallyGoodVocable = List.of({
        Vocable(id: 1, lectureId: 1, vocable: "voc1", vocableProgress: 0, vocableSort: "", media: "", mediaType: ""),
        Vocable(id: 2, lectureId: 1, vocable: "voc2", vocableProgress: 0, vocableSort: "", media: "", mediaType: ""),
        Vocable(id: 3, lectureId: 1, vocable: "voc3", vocableProgress: 0, vocableSort: "", media: "", mediaType: ""),
        Vocable(id: 4, lectureId: 1, vocable: "voc4", vocableProgress: 0, vocableSort: "", media: "", mediaType: ""),
        Vocable(id: 5, lectureId: 1, vocable: "voc5", vocableProgress: 0, vocableSort: "", media: "", mediaType: ""),
        Vocable(id: 6, lectureId: 1, vocable: "voc6", vocableProgress: 2, vocableSort: "", media: "", mediaType: ""),
      });

      Map resultMap1 = {};
      for (int i = 0; i < 1000; i++) {
        int index = Utils.chooseRandomVocable(true, listOf6WithOneReallyGoodVocable);
        if (resultMap1.containsKey(index)) {
          resultMap1.update(index, (value) => value + 1);
        } else {
          resultMap1.putIfAbsent(index, () => 1);
        }
      }
      log("Selection rate when vocable progress is enabled: \n$resultMap1");

      // Computing the average value
      int specialValue = resultMap1.remove(5);
      double? average = resultMap1.keys.map((key) {
        return resultMap1[key];
      }).toList().reduce((a, b) => a + b) / resultMap1.length;
      log("Special selection rate: $specialValue");
      log("Average selection rate: $average");

      expect(average, greaterThan(specialValue * 2));

      Map resultMap2 = {};
      for (int i = 0; i < 1000; i++) {
        int index = Utils.chooseRandomVocable(false, listOf6WithOneReallyGoodVocable);
        if (resultMap2.containsKey(index)) {
          resultMap2.update(index, (value) => value + 1);
        } else {
          resultMap2.putIfAbsent(index, () => 1);
        }
      }

      log("Selection rate when vocable progress is disabled: \n$resultMap2");
    });
  });
}
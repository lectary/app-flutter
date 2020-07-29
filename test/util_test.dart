import 'dart:developer';

import 'package:lectary/utils/utils.dart';
import 'package:test/test.dart';

void main() {
  test('currentDate should print date in format yyyy-MM-dd', () {
    String currentDate = Utils.currentDate();
    print("Current date: " + currentDate);

    expect(currentDate, ""
        "${DateTime.now().year}"
        "-${DateTime.now().month < 10 ? "0" + DateTime.now().month.toString() : DateTime.now().month}"
        "-${DateTime.now().day < 10 ? "0" + DateTime.now().day.toString() : DateTime.now().day}");
  });

  test('method should fill string with leading zeros up to length of 5', () {
    String sort1 = "1";
    String sort2 = "01";
    String sort3 = "001";
    String sort4 = "0001";
    String sort5 = "00001";

    sort1 = Utils.fillWithLeadingZeros(sort1);
    sort2 = Utils.fillWithLeadingZeros(sort2);
    sort3 = Utils.fillWithLeadingZeros(sort3);
    sort4 = Utils.fillWithLeadingZeros(sort4);
    sort5 = Utils.fillWithLeadingZeros(sort5);

    expect(sort1, "00001");
    expect(sort2, "00001");
    expect(sort3, "00001");
    expect(sort4, "00001");
    expect(sort5, "00001");
  });
}
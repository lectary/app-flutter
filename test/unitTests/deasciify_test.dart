import 'package:lectary/data/db/entities/coding.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/utils/utils.dart';
import 'package:test/test.dart';

void main() async {
  group('DeAsciify |', () {
    test('Test1 - successful deAsciify', () {
      List<Vocable> output = List.of({
        Vocable(vocable: "L_oewe_VAR1"),
        Vocable(vocable: "Nein___KKMund__offen_ZZ"),
        Vocable(vocable: "weiss__nein___KKMund__tief_ZZ"),
        Vocable(vocable: "Ja___KKKussmund_ZZ"),
        Vocable(vocable: "St_PPP_oelten"),
        Vocable(vocable: "_uebersetzen___KKschriftlich_ZZ"),
      });
      output.forEach((e) => e.vocable = Utils.deAsciify(e.vocable));

      List<Vocable> expectedOutput = List.of({
        Vocable(vocable: "Löwe (Variante 1)"),
        Vocable(vocable: "Nein (Mund offen)"),
        Vocable(vocable: "weiss nein (Mund tief)"),
        Vocable(vocable: "Ja (Kussmund)"),
        Vocable(vocable: "St.Pölten"),
        Vocable(vocable: "übersetzen (schriftlich)"),
      });

      expect(output.toString(), expectedOutput.toString());
    });

    test('Test2 - successful deAsciify with coding CZ', () {
      List<dynamic> json = [
        {"char": "Á", "asciify": "_CZXA"},
        {"char": "á", "asciify": "_CZXa"},
        {"char": "Č", "asciify": "_CZC"},
        {"char": "č", "asciify": "_CZc"},
        {"char": "Ď", "asciify": "_CZD"},
        {"char": "ď", "asciify": "_CZd"},
        {"char": "É", "asciify": "_CZXE"},
        {"char": "é", "asciify": "_CZXe"},
        {"char": "Ě", "asciify": "_CZE"},
        {"char": "é", "asciify": "_CZe"},
        {"char": "Í", "asciify": "_CZXI"},
        {"char": "í", "asciify": "_CZXi"},
        {"char": "Ň", "asciify": "_CZN"},
        {"char": "ň", "asciify": "_CZn"},
        {"char": "Ó", "asciify": "_CZXO"},
        {"char": "ó", "asciify": "_CZXo"},
        {"char": "Ř", "asciify": "_CZR"},
        {"char": "ř", "asciify": "_CZr"},
        {"char": "Š", "asciify": "_CZS"},
        {"char": "š", "asciify": "_CZs"},
        {"char": "Ť", "asciify": "_CZT"},
        {"char": "ť", "asciify": "_CZt"},
        {"char": "Ú", "asciify": "_CZXU"},
        {"char": "ú", "asciify": "_CZXu"},
        {"char": "Ů", "asciify": "_CZU"},
        {"char": "ů", "asciify": "_CZu"},
        {"char": "Ý", "asciify": "_CZXY"},
        {"char": "ý", "asciify": "_CZXy"},
        {"char": "Ž", "asciify": "_CZZ"},
        {"char": "ž", "asciify": "_CZz"}
      ];
      List<CodingEntry> coding = json
          .map((entry) =>
          CodingEntry(char: entry["char"], ascii: entry["asciify"]))
          .where((element) => element != null)
          .toList();

      Vocable vocable =  Vocable(vocable: "_CZXA_CZXa_CZC_CZc_CZD_CZd_CZXE_CZXe_CZE_CZe_CZXI_CZXi_CZN_CZn_CZXO_CZXo_CZR_CZr_CZS_CZs_CZT_CZt_CZXU_CZXu_CZU_CZu_CZXY_CZXy_CZZ_CZz");
      String output = Utils.deAsciify(vocable.vocable, codingEntries: coding);

      String expectedOutput = "ÁáČčĎďÉéĚéÍíŇňÓóŘřŠšŤťÚúŮůÝýŽž";

      expect(output, expectedOutput);
    });
  });
}
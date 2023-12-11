import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/data/repositories/lecture_repository.dart';
import 'package:lectary/i18n/localizations.dart';
import 'package:lectary/screens/lectures/search/vocable_search_screen.dart';
import 'package:lectary/viewmodels/carousel_viewmodel.dart';
import 'package:lectary/viewmodels/setting_viewmodel.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../shared_mocks.mocks.dart';

@GenerateMocks([LectureRepository])
void main() async {
  group('Testing elements of search result screen |', () {
    List<Lecture> mockLectures = List.of({
      Lecture(
          id: 1,
          fileName: "",
          fileSize: 5,
          vocableCount: 5,
          pack: "",
          lesson: "",
          lessonSort: "",
          langVocable: "CZ",
          langMedia: "ÖGS",
          date: '2021-04-04'),
      Lecture(
          id: 2,
          fileName: "",
          fileSize: 5,
          vocableCount: 5,
          pack: "",
          lesson: "",
          lessonSort: "",
          langVocable: "CZ",
          langMedia: "ÖGS",
          date: '2021-04-04'),
      Lecture(
          id: 3,
          fileName: "",
          fileSize: 5,
          vocableCount: 5,
          pack: "",
          lesson: "",
          lessonSort: "",
          langVocable: "CZ",
          langMedia: "ÖGS",
          date: '2021-04-04')
    });
    List<Vocable> vocablesWithDuplicates = List.of({
      Vocable(id: 1, lectureId: 1, vocable: "Haus", vocableSort: "Haus", media: "", mediaType: "PNG"),
      Vocable(id: 2, lectureId: 1, vocable: "Haus", vocableSort: "Haus", media: "", mediaType: "TXT"),
      Vocable(id: 3, lectureId: 2, vocable: "Haus", vocableSort: "Haus", media: "", mediaType: "MP4"),
      Vocable(id: 4, lectureId: 3, vocable: "Baum", vocableSort: "Haus", media: "", mediaType: "TXT")
    });

    testWidgets('Test1 - testing correct appearance with vocable duplicates', (WidgetTester tester) async {
      final mockRepo = MockLectureRepository();

      when(mockRepo.findVocablesByLangMedia("ÖGS")).thenAnswer((_) async => Future.value(vocablesWithDuplicates));
      when(mockRepo.watchAllLectures()).thenAnswer((_) => Stream<List<Lecture>>.value(mockLectures));

      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<SettingViewModel>(
                create: (BuildContext context) =>
                    SettingViewModel(lectureRepository: mockRepo)..settingLearningLanguage = "ÖGS"),
            ChangeNotifierProxyProvider<SettingViewModel, CarouselViewModel>(
                create: (BuildContext context) => CarouselViewModel(lectureRepository: mockRepo),
                update: (context, SettingViewModel settingViewModel, CarouselViewModel? carouselViewModel) =>
                    carouselViewModel!
                      ..updateSettings(settingViewModel)
                      ..loadAllVocables(saveSelection: false),
                lazy: false),
          ],
          child: MaterialApp(
            navigatorKey: key,
            locale: const Locale('de', 'DE'),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              // following localizations are needed!
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate
            ],
            supportedLocales: const [
              Locale('de', 'DE'),
            ],
            title: 'Flutter Test Wrapper',
            home: TextButton(
              onPressed: () => key.currentState!.push(
                MaterialPageRoute<void>(
                    settings: RouteSettings(arguments: VocableSearchScreenArguments(navigationOnly: false)),
                    builder: (_) => const VocableSearchScreen()),
              ),
              child: const SizedBox(),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // assert title
      final titleFinder = find.text('Alle Vokabel');
      expect(titleFinder, findsOneWidget);

      // assert number of duplicates
      final listElementFinder1 = find.text("Haus");
      expect(listElementFinder1, findsNWidgets(3));

      // assert number of non-duplicates
      final listElementFinder2 = find.text("Baum");
      expect(listElementFinder2, findsOneWidget);

      // assert icons
      final listElementIconFinder1 = find.byIcon(Icons.movie);
      expect(listElementIconFinder1, findsOneWidget);
      final listElementIconFinder2 = find.byIcon(Icons.insert_photo);
      expect(listElementIconFinder2, findsOneWidget);
      final listElementIconFinder3 = find.byIcon(Icons.subject);
      expect(listElementIconFinder3, findsOneWidget);

      // assert correct search result
      await tester.enterText(find.byType(TextField), "Baum");
      await tester.pumpAndSettle();

      final findBaumElement = find.descendant(of: find.byType(ListView), matching: find.text("Baum"));
      expect(findBaumElement, findsOneWidget);
      expect(find.byIcon(Icons.subject), findsNothing);
      expect(find.text("Haus"), findsNothing);
    });
  });
}

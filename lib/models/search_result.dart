import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/screens/lectures/search/vocable_search_screen.dart';

/// Model class representing all searchResults grouped by their lecture name.
/// It is used by the [VocableSearchScreen]
/// Contains mandatory [Lecture.lesson] and a list of [SearchResult]
class SearchResultPackage {
  final String lectureTitle;
  final List<SearchResult> children;

  SearchResultPackage(this.lectureTitle, this.children);
}

/// Model class representing a searchResult used by the [VocableSearchScreen]
/// Contains mandatory [Vocable] and optional [Vocable.mediaType]
class SearchResult {
  final Vocable vocable;
  String mediaType;

  SearchResult(this.vocable, {this.mediaType});
}
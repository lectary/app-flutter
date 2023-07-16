import 'package:flutter/material.dart';
import 'package:lectary/data/db/entities/lecture.dart';
import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/screens/lectures/search/vocable_search_screen.dart';

/// Value object to implemented a list view with multiple level of children.
///
/// Case: We have a list view with [SearchResultPackage] where we want to expand its [SearchResultPackage.children]
/// into another nested list view. Nested list views are not really supported. Implementing it naively, leads to the bug,
/// that every list of children will be build, because the list view cannot determine, whether they are visible or not.
///
/// Two workarounds are available:
/// 1. Use [CustomScrollView] with [SliverList] to implement arbitrary custom nested list views.
/// 2. Flatten the structure into a single list, and then decide how to render each item based on its
/// nesting level.
///
/// The second approach is taken here.
@immutable
abstract class SearchResultItem {}

class ItemHeader implements SearchResultItem {
  final String lectureTitle;

  ItemHeader(this.lectureTitle);
}

class ItemRow implements SearchResultItem {
  final SearchResult searchResult;

  ItemRow(this.searchResult);
}

/// Helper class for realizing categorization of [SearchResult] by [Lecture.lesson].
/// Creates a special [ListTile] header with the lecture name and maps
/// its children list of [SearchResult] to a standard [ListTile].
/// If [showPackage] is false, then the [ListTile] header for the package is omitted.

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
  String? mediaType;

  SearchResult(this.vocable, {this.mediaType});
}
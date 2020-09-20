import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/models/media_type_enum.dart';

class SearchResultPackage {
  final String lectureTitle;
  final List<SearchResult> children;

  SearchResultPackage(this.lectureTitle, this.children);
}

class SearchResult {
  final Vocable vocable;
  String mediaType;

  SearchResult(this.vocable, {this.mediaType});
}
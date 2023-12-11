import 'package:lectary/utils/exceptions/media_type_exception.dart';

enum MediaType implements Comparable<MediaType> {
  mp4('mp4', 0),
  jpg('jpg', 1),
  png('png', 1),
  txt('txt', 2);

  const MediaType(
    this.name,
    this.order,
  );

  final String name;
  final int order;

  @override
  String toString() {
    return name;
  }

  static MediaType fromString(String typeAsString) {
    for (MediaType element in values) {
      if (element.name == typeAsString.toLowerCase()) {
        return element;
      }
    }
    throw MediaTypeException("Type is not supported");
  }

  @override
  int compareTo(MediaType other) => order - other.order;
}

import 'package:lectary/data/db/entities/vocable.dart';
import 'package:lectary/utils/exceptions/media_type_exception.dart';


/// Pseudo enum class for the media-type of [Vocable].
/// Due to the restrictions in functionality of real enum-classes,
/// this helper class representing the media-type enum is used.
class MediaType {
  const MediaType._(this._name);

  final String _name;

  static const MediaType MP4 = MediaType._('mp4');
  static const MediaType JPG = MediaType._('jpg');
  static const MediaType PNG = MediaType._('png');
  static const MediaType TXT = MediaType._('txt');

  static final List<MediaType> _values = List.of({
    MediaType.MP4,
    MediaType.JPG,
    MediaType.PNG,
    MediaType.TXT
  });

  @override
  String toString() {
    return _name;
  }

  static MediaType fromString(String typeAsString) {
    for (MediaType element in _values) {
      if (element.toString() == typeAsString.toLowerCase()) {
        return element;
      }
    }
    throw new MediaTypeException("Type is not supported");
  }
}


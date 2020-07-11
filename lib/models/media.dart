import 'package:lectary/models/media_type.dart';

class Media {
  int mediaId;
  int lectureId;

  MediaType mediaType;
  String vocable;
  String content; // can contain a path to the video or image or the text content

  Media({this.lectureId, this.mediaType, this.vocable, this.content});
}
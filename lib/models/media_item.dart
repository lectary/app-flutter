abstract class MediaItem {
  final String text;
  final String media;

  MediaItem(this.text, this.media);
}

class VideoItem extends MediaItem {
  VideoItem({String text, String media}) : super(text, media);
}

class PictureItem extends MediaItem {
  PictureItem({String text, String media}) : super(text, media);

}

class TextItem extends MediaItem {
  TextItem({String text, String media}) : super(text, media);
}
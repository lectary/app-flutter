enum MediaType {
  MP4, JPG, PNG, TXT
}

MediaType getMediaTypeFromString(String typeAsString) {
  for (MediaType element in MediaType.values) {
    if (element.toString() == "MediaType." + typeAsString) {
      return element;
    }
  }
  throw new Exception("Type is not supported");
}
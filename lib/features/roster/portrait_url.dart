/// Request a consistent face-centered square from the NFL's image CDN.
/// Replace existing thumbnail transforms so detection uses the original photo.
/// Other providers keep their original URL; their pixels are centered by Flutter.
String portraitUrl(String source) {
  final uri = Uri.tryParse(source);
  if (uri == null ||
      uri.scheme != 'https' ||
      !{'static.clubs.nfl.com', 'static.www.nfl.com'}.contains(uri.host)) {
    return source;
  }
  final parts = uri.pathSegments;
  if (parts.length < 4 ||
      parts[0] != 'image' ||
      !{'upload', 'private'}.contains(parts[1])) {
    return source;
  }
  var start = 2;
  // Transformation components precede the asset namespace (steelers, league…).
  while (start < parts.length && RegExp(r'^[a-z]+_').hasMatch(parts[start])) {
    start++;
  }
  if (start >= parts.length) return source;
  return uri
      .replace(
        path:
            '/image/${parts[1]}/'
            'c_thumb,g_face,z_0.65,w_400,h_400/f_auto,q_auto/'
            '${parts.skip(start).join('/')}',
      )
      .toString();
}

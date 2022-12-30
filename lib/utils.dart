bool isUrlValid(String? url) {
  return Uri.tryParse(url.toString())?.isAbsolute ?? false;
}

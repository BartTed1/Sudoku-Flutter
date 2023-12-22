class ValueExistsException implements Exception {
  final String message;

  ValueExistsException(this.message);

  @override
  String toString() {
    return message;
  }
}

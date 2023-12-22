class AddressDoesNotExistException implements Exception {
  final String message;

  AddressDoesNotExistException(this.message);

  @override
  String toString() {
    return message;
  }
}

class Failure {
  Failure({
    required this.message,
    this.title = 'Error',
    this.rawData = const {},
    this.errorCode,
  });

  final String message;
  final String title;
  final Map<String, dynamic> rawData;
  final String? errorCode;
}

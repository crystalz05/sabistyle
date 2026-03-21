/// Every layer throws this. The BLoC catches it and maps it to a state.
class AppException implements Exception {
  const AppException(this.message, {this.code});

  final String message;
  final String? code; // Supabase error code when available

  @override
  String toString() => 'AppException($code): $message';
}
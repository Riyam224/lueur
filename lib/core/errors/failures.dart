abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// User deliberately cancelled an operation (e.g. dismissed Google sign-in).
/// Cubits should handle this silently — no error state, no snackbar.
class CancellationFailure extends Failure {
  const CancellationFailure() : super('Operation cancelled');
}

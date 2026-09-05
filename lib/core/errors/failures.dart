abstract class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// No internet connection reached the server at all (as opposed to a
/// server-side error) — lets callers show a friendly offline message
/// instead of the raw connection error.
class NetworkOfflineFailure extends Failure {
  const NetworkOfflineFailure() : super('No internet connection');
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// User deliberately cancelled an operation (e.g. dismissed Google sign-in).
/// Cubits should handle this silently — no error state, no snackbar.
class CancellationFailure extends Failure {
  const CancellationFailure() : super('Operation cancelled');
}

/// A guest tried to talk with Luna. Guests must never reach the AI backend —
/// this is returned before any network call is attempted.
class GuestSignInRequiredFailure extends Failure {
  const GuestSignInRequiredFailure() : super('Sign in to talk with Luna');
}

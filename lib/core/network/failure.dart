abstract class Failure{
  final String message;

  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure()
      : super('No internet connection.');
}

class ServerFailure extends Failure {
  const ServerFailure()
      : super('Server error.');
}

class TimeoutFailure extends Failure {
  const TimeoutFailure()
      : super('Request timed out.');
}

class UnknownFailure extends Failure {
  const UnknownFailure()
      : super('Something went wrong.');
}
import 'failure.dart';
abstract class Result<T> {

    R fold<R>(
    R Function(Failure failure) onFailure,
    R Function(T data) onSuccess,
  ) {
    final self = this;
    if (self is Success<T>) return onSuccess(self.data);
    if (self is FailureResult<T>) return onFailure(self.failure);
    throw StateError('Unhandled Result subtype');
  }

}

class Success<T> extends Result<T>{
  final T data;

  Success(this.data);
}

class FailureResult<T> extends Result<T>{
  final Failure failure;

  FailureResult(this.failure);
}
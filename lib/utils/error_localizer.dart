import 'package:doctorly/utils/repository_exception.dart';

String localizeError(Object error) {
  if (error is RepositoryException) {
    switch (error.kind) {
      case RepositoryExceptionKind.network:
        return 'Network issue. Please check your connection and retry.';
      case RepositoryExceptionKind.notFound:
        return 'The requested item could not be found.';
      case RepositoryExceptionKind.unauthorized:
        return 'You are not authorized to perform this action.';
      case RepositoryExceptionKind.unknown:
        return 'Something went wrong. Please try again.';
    }
  }
  return 'Something went wrong. Please try again.';
}

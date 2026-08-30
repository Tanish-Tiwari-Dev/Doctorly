enum RepositoryExceptionKind { network, notFound, unauthorized, unknown }

class RepositoryException implements Exception {
  const RepositoryException(this.kind, this.message);

  final RepositoryExceptionKind kind;
  final String message;

  @override
  String toString() => message;
}

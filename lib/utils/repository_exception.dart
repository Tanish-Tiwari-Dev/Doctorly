import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Categories of repository-level errors encountered during data operations.
enum RepositoryExceptionKind {
  /// Connection failures, timeouts, or socket errors.
  network,

  /// Resource not found (404 errors).
  notFound,

  /// Authentication or authorization failure (401/403 errors).
  unauthorized,

  /// General or unknown error condition.
  unknown,
}

/// Domain exception encapsulating data-access errors across repositories.
///
/// Wraps underlying exceptions (e.g. [PostgrestException], [SocketException])
/// with a categorized [kind] and a sanitized human-readable [message].
class RepositoryException implements Exception {
  /// Creates a [RepositoryException] with the specified [kind] and [message].
  const RepositoryException(this.kind, this.message);

  /// The error category classification.
  final RepositoryExceptionKind kind;

  /// Human-readable message describing the exception.
  final String message;

  @override
  String toString() => message;
}

/// Classifies a raw exception [e] into a [RepositoryExceptionKind].
///
/// Returns [RepositoryExceptionKind.network] for network issues,
/// [RepositoryExceptionKind.unauthorized] for auth failures,
/// [RepositoryExceptionKind.notFound] for 404s, and
/// [RepositoryExceptionKind.unknown] for unclassified errors.
RepositoryExceptionKind classifyError(Object e) {
  if (e is RepositoryException) {
    return e.kind;
  }
  if (e is AuthException) {
    return RepositoryExceptionKind.unauthorized;
  }
  if (e is PostgrestException) {
    if (e.code == '401' || e.code == '403' || e.code == 'PGRST301') {
      return RepositoryExceptionKind.unauthorized;
    }
    return e.code == '404' || (e.details?.toString().contains('404') ?? false)
        ? RepositoryExceptionKind.notFound
        : RepositoryExceptionKind.unknown;
  }
  if (e is SocketException || e is TimeoutException) {
    return RepositoryExceptionKind.network;
  }
  return RepositoryExceptionKind.unknown;
}

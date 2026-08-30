import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

enum RepositoryExceptionKind { network, notFound, unauthorized, unknown }

class RepositoryException implements Exception {
  const RepositoryException(this.kind, this.message);

  final RepositoryExceptionKind kind;
  final String message;

  @override
  String toString() => message;
}

RepositoryExceptionKind classifyError(Object e) {
  if (e is PostgrestException) {
    return e.code == '404' || (e.details?.toString().contains('404') ?? false)
        ? RepositoryExceptionKind.notFound
        : RepositoryExceptionKind.unknown;
  }
  if (e is SocketException || e is TimeoutException) {
    return RepositoryExceptionKind.network;
  }
  return RepositoryExceptionKind.unknown;
}

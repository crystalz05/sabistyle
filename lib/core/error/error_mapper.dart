import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'app_exception.dart';
// ignore: depend_on_referenced_packages
import 'package:postgrest/postgrest.dart';

class ErrorMapper {
  static AppException fromError(Object error) {
    if (error is AppException) return error;

    final errorString = error.toString().toLowerCase();
    
    // Catch common network exceptions and wrapped platform exceptions first,
    // because Supabase might wrap them in AuthFetchException or AuthException.
    if (error is SocketException ||
        error is TimeoutException ||
        errorString.contains('socketexception') ||
        errorString.contains('failed host lookup') ||
        errorString.contains('connection reset by peer') ||
        errorString.contains('connection refused') ||
        errorString.contains('network is unreachable')) {
      return const AppException('No internet connection. Please check your network and try again.');
    }

    if (errorString.contains('timeout')) {
      return const AppException('The request timed out. Please try again.');
    }

    // Handle Supabase database / PostgREST errors
    if (error is PostgrestException) {
      return AppException(
        error.message.isNotEmpty
            ? error.message
            : 'A database error occurred. Please try again.',
        code: error.code,
      );
    }

    // Now handle generic Supabase auth API errors
    if (error is AuthException) {
      return AppException(_mapAuthMessage(error.message), code: error.statusCode);
    }

    return const AppException('An unexpected error occurred. Please try again.');
  }

  static String _mapAuthMessage(String raw) {
    final msg = raw.toLowerCase();
    if (msg.contains('invalid login credentials')) return 'Incorrect email or password.';
    if (msg.contains('email not confirmed')) return 'Please verify your email before signing in.';
    if (msg.contains('user already registered')) return 'An account with this email already exists.';
    if (msg.contains('password should be at least')) return 'Password must be at least 6 characters.';
    if (msg.contains('rate limit')) return 'Too many attempts. Please wait a moment and try again.';
    return raw;
  }
}

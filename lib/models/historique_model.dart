import 'package:flutter/foundation.dart';

/// Represents a single history log entry.
/// This class is immutable.
@immutable
class Historique {
  final int? id;
  final String action;
  final DateTime timestamp;

  const Historique({
    this.id,
    required this.action,
    required this.timestamp,
  });

  /// Converts a [Historique] instance into a `Map`.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Creates a [Historique] instance from a `Map`.
  factory Historique.fromMap(Map<String, dynamic> map) {
    return Historique(
      id: map['id'] as int?,
      action: map['action'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
} 
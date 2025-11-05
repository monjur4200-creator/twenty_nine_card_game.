import 'package:flutter/foundation.dart';

/// Logs animation events for debugging or replay.
class AnimationLogger {
  static final List<String> _log = [];

  /// Adds a new animation event to the log.
  static void logEvent(String label, {Map<String, dynamic>? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final entry = '[$timestamp] $label'
        '${data != null ? ' → ${_formatData(data)}' : ''}';
    _log.add(entry);
    debugPrint(entry);
  }

  /// Returns the full log.
  static List<String> getLog() => List.unmodifiable(_log);

  /// Clears the log.
  static void clear() => _log.clear();

  static String _formatData(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}: ${e.value}').join(', ');
  }
}

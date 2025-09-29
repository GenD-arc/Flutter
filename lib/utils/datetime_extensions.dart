import 'package:intl/intl.dart';

/// Extension for converting UTC DateTime into Philippine Time (UTC+8)
/// and formatting it in a reusable way.
extension DateTimePhFormat on DateTime {
  /// Returns a DateTime converted to PH time (UTC+8).
  DateTime get toPhTime => toUtc().add(const Duration(hours: 8));

  /// Formats the DateTime into a PH time string.
  String toPhString({String pattern = "MMM d, yyyy hh:mm a"}) {
    return DateFormat(pattern).format(toPhTime);
  }
}

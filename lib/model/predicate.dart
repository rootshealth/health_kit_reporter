import 'package:health_kit_reporter/health_kit_reporter.dart';

/// A time interval predicate used in
/// most of query requests of [HealthKitReporter]
///
/// [startDate] - the starting point of the time interval
/// [endDate] - the end point of the time interval
///
/// For native calls the instance will be mapped to [map]
/// and timestamps values will be accepted as arguments.
///
class Predicate {
  const Predicate(
    this.startDate,
    this.endDate, {
    this.options = const {
      QueryOptions.strictEndDate,
      QueryOptions.strictStartDate,
    },
  });

  final DateTime startDate;
  final DateTime endDate;
  final Set<QueryOptions> options;

  /// General map representation
  ///
  Map<String, Object> get map => {
        'startTimestamp': startDate.millisecondsSinceEpoch,
        'endTimestamp': endDate.millisecondsSinceEpoch,
        'options': [...options.map((e) => e.name)]
      };
}

/// equivalent to: https://developer.apple.com/documentation/healthkit/hkqueryoptions
enum QueryOptions {
  strictStartDate,
  strictEndDate,
}

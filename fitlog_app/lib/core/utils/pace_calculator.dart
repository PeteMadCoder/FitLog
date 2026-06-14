class PaceCalculator {
  /// Calculates pace in minutes per kilometer from speed in meters per second.
  /// Returns null if speed is too low or invalid.
  static double? calculatePaceMinPerKm(double speedMetersPerSecond) {
    if (speedMetersPerSecond <= 0.05) return null;
    // 1 m/s = 3.6 km/h. Pace (min/km) = 60 / (speed in km/h)
    return 60.0 / (speedMetersPerSecond * 3.6);
  }

  /// Calculates average pace from duration and distance in meters.
  /// Returns null if distance is zero or invalid.
  static double? calculateAveragePaceMinPerKm(Duration duration, double distanceMeters) {
    if (distanceMeters <= 1.0) return null;
    final distanceKm = distanceMeters / 1000.0;
    final minutes = duration.inSeconds / 60.0;
    return minutes / distanceKm;
  }

  /// Formats pace in minutes per kilometer to a standard "MM:SS" representation.
  /// Returns "--:--" if pace is invalid or null.
  static String formatPace(double? paceMinPerKm) {
    if (paceMinPerKm == null || paceMinPerKm.isInfinite || paceMinPerKm.isNaN || paceMinPerKm < 0) {
      return '--:--';
    }
    final minutes = paceMinPerKm.floor();
    final seconds = ((paceMinPerKm - minutes) * 60).round();

    var adjustedMinutes = minutes;
    var adjustedSeconds = seconds;
    if (adjustedSeconds >= 60) {
      adjustedMinutes += 1;
      adjustedSeconds -= 60;
    }

    final secondsStr = adjustedSeconds.toString().padLeft(2, '0');
    return '$adjustedMinutes:$secondsStr';
  }
}

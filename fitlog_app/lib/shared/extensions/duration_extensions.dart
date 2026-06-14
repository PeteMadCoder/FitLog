/// Extensions on [Duration] for formatting workout metrics.
extension DurationFormat on Duration {
  /// Formats the duration into a string as `HH:MM:SS` or `MM:SS` if less than an hour.
  String toHoursMinutesSeconds() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }
}

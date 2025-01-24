class Habit {
  final String title;
  final String description;
  final String color;
  final List<DateTime> completedDates;
  final int? duration; // Duration in minutes
  final bool isTimerRunning;

  Habit({
    required this.title,
    required this.description,
    required this.color,
    List<DateTime>? completedDates,
    this.duration,
    this.isTimerRunning = false,
  }) : completedDates = completedDates ?? [];
}

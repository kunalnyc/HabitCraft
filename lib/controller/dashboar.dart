import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/Logic/habit.dart';
import 'package:habit_tracker/controller/habit_controller.dart';

class ProgressDashboard extends StatelessWidget {
  final HabitController habitController = Get.find<HabitController>();
  final Habit habit;

  ProgressDashboard({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(title: const Text("Dashboard")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Task of the Day",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                "Duration: ${habit.duration ?? 0} minutes", // Handle null safely
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),
              // Task completion progress
              _buildTaskCompletionProgress(),
              const SizedBox(height: 20),
              // Total duration bar chart
              _buildTotalDurationChart(),
              const SizedBox(height: 20),
              // Recommendation for more minutes
              _buildRecommendation(),
              const SizedBox(height: 20),
              // Weekly progress chart
              _buildWeeklyProgressChart(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCompletionProgress() {
    final completedTasks =
        habitController.habitList
            .where((habit) => habit.completedDates.contains(DateTime.now()))
            .length;
    final totalTasks = habitController.habitList.length;

    final progress = totalTasks == 0 ? 0.0 : (completedTasks / totalTasks);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Completed Tasks: $completedTasks / $totalTasks",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation(Colors.green),
          minHeight: 12,
        ),
      ],
    );
  }

  Widget _buildTotalDurationChart() {
    final totalDuration = habitController.habitList
        .where((habit) => habit.completedDates.contains(DateTime.now()))
        .fold(0, (sum, habit) => sum + (habit.duration ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Total Duration Today: $totalDuration minutes",
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        _buildDurationChart(totalDuration.toDouble()),
      ],
    );
  }

  Widget _buildDurationChart(double totalDuration) {
    final taskDurations =
        habitController.habitList
            .where((habit) => habit.completedDates.contains(DateTime.now()))
            .map((habit) => habit.duration ?? 0)
            .toList();

    final taskNames =
        habitController.habitList
            .where((habit) => habit.completedDates.contains(DateTime.now()))
            .map((habit) => habit.title)
            .toList();

    return SizedBox(
      height: 300,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barGroups:
              taskDurations.asMap().entries.map((entry) {
                final index = entry.key;
                final duration = entry.value;

                final remainingTime =
                    habit.duration! - duration; // Remaining time for task

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: duration.toDouble(),
                      color: Colors.blue,
                      width: 20,
                    ),
                    BarChartRodData(
                      toY: remainingTime.toDouble(),
                      color: Colors.grey[300]!,
                      width: 20,
                    ),
                  ],
                );
              }).toList(),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      taskNames[index],
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildRecommendation() {
    final totalDuration = habitController.habitList
        .where((habit) => habit.completedDates.contains(DateTime.now()))
        .fold(0, (sum, habit) => sum + (habit.duration ?? 0));

    String recommendationText = "";
    if (totalDuration < 30) {
      recommendationText = "Try to do at least 30 minutes more!";
    } else if (totalDuration < 60) {
      recommendationText = "You're doing great! Aim for 60 minutes today!";
    } else {
      recommendationText = "Awesome! Keep up the great work!";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recommendation:",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          recommendationText,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgressChart() {
    List<FlSpot> spots = _generateWeeklyProgress();

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 12),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][value
                          .toInt()],
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: Colors.blue,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateWeeklyProgress() {
    List<FlSpot> spots = [];
    final today = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = today.subtract(Duration(days: i));
      final completedDuration = habitController.habitList
          .where((habit) => habit.completedDates.contains(date))
          .fold(0, (sum, habit) => sum + (habit.duration ?? 0));

      spots.add(FlSpot(i.toDouble(), completedDuration.toDouble()));
    }

    if (spots.isEmpty) {
      spots.add(FlSpot(0, 0)); // Add a default spot in case there's no data
    }

    return spots;
  }
}

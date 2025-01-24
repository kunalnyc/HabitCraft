import 'package:get/get.dart';
import 'package:habit_tracker/Logic/habit.dart';
import 'package:hive/hive.dart';

class HabitController extends GetxController {
  var habitList = <Habit>[].obs;
  var completedTasks = <Habit>[].obs;
  var selectedDay = Rx<DateTime>(DateTime.now());
  var completedDates = <String>[].obs; // Store completed dates as strings (yyyy-mm-dd)

  @override
  void onInit() {
    super.onInit();
    loadHabits();
  }

  // Load habits from Hive
  void loadHabits() async {
    var box = await Hive.openBox<Habit>('habits');
    habitList.value = box.values.toList();
  }

  // Add new habit
  void addHabit(Habit habit) async {
    var box = await Hive.openBox<Habit>('habits');
    await box.add(habit); // Store habit in Hive
    habitList.add(habit); // Update local habit list
  }

  // Delete habit
  void deleteHabit(Habit habit) async {
    var box = await Hive.openBox<Habit>('habits');
    final key = box.keys.firstWhere((k) => box.get(k) == habit);
    await box.delete(key); // Remove habit from Hive
    habitList.remove(habit); // Update local habit list
  }

  // Mark habit as completed or incomplete for today
  Future<void> markHabitCompleted(Habit habit, DateTime date) async {
    completedTasks.add(habit);
    habitList.remove(habit);
    update(); // Update UI
    final today = DateTime(date.year, date.month, date.day); // Ignore time

    // Add today's date as a string (yyyy-mm-dd format)
    String todayString = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    
    // Add to completedDates list
    if (!completedDates.contains(todayString)) {
      completedDates.add(todayString); // Add today's date to the list
    }

    // Save updated habit back to Hive
    var box = await Hive.openBox<Habit>('habits');
    final key = box.keys.firstWhere((k) => box.get(k) == habit);
    await box.put(key, habit); // Update habit in Hive

    // Refresh habit list to reflect the changes
    habitList.refresh();

    // Update the UI by notifying that the habit is completed for today
    Get.snackbar(
      "Habit Completed!",
      "${habit.title} completed for today!",
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

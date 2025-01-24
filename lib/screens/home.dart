// ignore_for_file: avoid_print

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/Logic/habit.dart';
import 'package:habit_tracker/controller/dashboar.dart';
import 'package:habit_tracker/controller/habit_controller.dart';
import 'package:habit_tracker/screens/add_habit.dart';
import 'package:habit_tracker/screens/habit_widget.dart';
import 'package:table_calendar/table_calendar.dart';

class HomeScreen extends StatelessWidget {
  final HabitController habitController = Get.put(HabitController());
  final RxBool isCalendarVisible = RxBool(true); // State to control visibility

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "HabitCraft",
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 24,
            color: CupertinoColors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 226, 40, 143),
                Color.fromARGB(255, 0, 0, 0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Obx(() {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Button to toggle calendar visibility
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoButton(
                    color: Colors.black,
                    onPressed: () {
                      isCalendarVisible.value =
                          !isCalendarVisible.value; // Toggle the state
                    },
                    child: Text(
                      isCalendarVisible.value
                          ? 'Today Routine'
                          : 'Track Routine',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoButton(
                    color: Colors.pinkAccent,
                    onPressed: () {
                      Get.to(() => AddHabitScreen());
                    },
                    child: Text(
                      'Add new routine',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),

            // Conditionally showing the calendar based on the state
            if (isCalendarVisible.value)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2025, 12, 31),
                  focusedDay: DateTime.now(),
                  calendarFormat: CalendarFormat.month,
                  onDaySelected: (selectedDay, focusedDay) {
                    habitController.selectedDay.value = selectedDay;

                    // Compare only the date part of the DateTime objects (ignoring time)
                    final today = DateTime.now();
                    final selectedDate = DateTime(
                      selectedDay.year,
                      selectedDay.month,
                      selectedDay.day,
                    );
                    final todayDate = DateTime(
                      today.year,
                      today.month,
                      today.day,
                    );

                    // Print the selected and today's date for debugging
                    print(
                      "Selected Date: $selectedDate, Today's Date: $todayDate",
                    );

                    // Show a popup if the selected day is today
                    if (selectedDate.isAtSameMomentAs(todayDate)) {
                      _showTodayCompletedTasks(context);
                    }
                  },

                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blueAccent,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                    selectedTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.white,
                    ),
                  ),
                  headerStyle: HeaderStyle(formatButtonVisible: false),
                ),
              ),

            // Displaying Completed Tasks for Today
            if (habitController.completedTasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Completed Tasks Today",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: habitController.completedTasks.length,
                      itemBuilder: (context, index) {
                        final habit = habitController.completedTasks[index];
                        return _buildCompletedTaskCard(habit);
                      },
                    ),
                  ],
                ),
              ),

            // Displaying Active Tasks
            Expanded(
              child:
                  habitController.habitList.isEmpty
                      ? Center(
                        child: Text(
                          "No habits yet. Add some!",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        itemCount: habitController.habitList.length,
                        itemBuilder: (context, index) {
                          final habit = habitController.habitList[index];
                          return InkWell(
                            onTap: () {
                              Get.to(() => ProgressDashboard(habit: habit));
                            },
                            child: Card(
                              elevation: 6,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              color: const Color.fromARGB(255, 0, 0, 0),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              habit.title,
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: const Color.fromARGB(
                                                  255,
                                                  255,
                                                  255,
                                                  255,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              habit.description,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: const Color.fromARGB(
                                                  255,
                                                  187,
                                                  187,
                                                  187,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            Icons.delete,
                                            color: Colors.redAccent,
                                            size: 26,
                                          ),
                                          onPressed: () {
                                            habitController.deleteHabit(habit);
                                          },
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    if (habit.duration != null)
                                      TimerWidget(
                                        initialDuration: habit.duration!,
                                        onTimerComplete: () {
                                          habitController.markHabitCompleted(
                                            habit,
                                            DateTime.now(),
                                          );
                                          Get.snackbar(
                                            "Habit Completed!",
                                            "${habit.title} completed for today!",
                                            snackPosition: SnackPosition.BOTTOM,
                                            backgroundColor: Colors.greenAccent,
                                            colorText: Colors.white,
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
            ),
          ],
        );
      }),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddHabitScreen());
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color.fromARGB(255, 17, 0, 11),
        child: const Icon(Icons.add, size: 30, color: CupertinoColors.white),
      ),
    );
  }

  Widget _buildCompletedTaskCard(Habit habit) {
    final totalDuration = habitController.habitList
        .where((habit) => habit.completedDates.contains(DateTime.now()))
        .fold(0, (sum, habit) => sum + (habit.duration ?? 0));
    return Card(
      color: Colors.green[50],
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      habit.description,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(width: 5),
                    Text(
                      '(${habit.duration} min)',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Icon(Icons.check_circle, color: Colors.green, size: 30),
          ],
        ),
      ),
    );
  }

  // Show popup for today completed tasks
  void _showTodayCompletedTasks(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Today's Completed Tasks"),
          content: SizedBox(
            height: 200,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: habitController.completedTasks.length,
              itemBuilder: (context, index) {
                final habit = habitController.completedTasks[index];
                return ListTile(
                  title: Text(habit.title),
                  subtitle: Text(habit.description),
                  trailing: Text(
                    '${habit.duration} min',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: Icon(Icons.check_circle, color: Colors.green),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }
}

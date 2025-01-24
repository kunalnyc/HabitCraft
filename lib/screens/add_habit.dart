import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/Logic/habit.dart';
import 'package:habit_tracker/controller/habit_controller.dart';

class AddHabitScreen extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController durationController = TextEditingController();
  final HabitController habitController = Get.find<HabitController>();

  AddHabitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add New Habit")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: "Habit Title",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: "Habit Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: durationController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Duration (minutes)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    durationController.text.isNotEmpty) {
                  final duration = int.tryParse(durationController.text);
                  if (duration != null && duration > 0) {
                    // Create a new Habit object
                    final newHabit = Habit(
                      title: titleController.text,
                      description: descriptionController.text,
                      color: "blue", // Default color for now
                      completedDates: [],
                      duration: duration, // Add duration here
                    );

                    // Add the habit via the controller
                    habitController.addHabit(newHabit);

                    // Navigate back
                    Get.back();
                  } else {
                    Get.snackbar(
                      "Invalid Input",
                      "Please enter a valid duration in minutes.",
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                } else {
                  Get.snackbar(
                    "Error",
                    "Please fill out all fields.",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Text("Add Habit"),
            ),
          ],
        ),
      ),
    );
  }
}

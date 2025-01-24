import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimerWidget extends StatefulWidget {
  final int initialDuration; // in minutes
  final VoidCallback onTimerComplete;

  const TimerWidget({
    super.key,
    required this.initialDuration,
    required this.onTimerComplete,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late int secondsRemaining;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    secondsRemaining =
        widget.initialDuration * 60; // Convert minutes to seconds
  }

  void startTimer() async {
    Get.snackbar(
      "Started Now",
      "Timer is started for the habit.",
      snackPosition: SnackPosition.BOTTOM,
    );
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        timer.cancel();
        widget.onTimerComplete(); // Notify parent when timer completes
        await _saveProgress(); // Save the session data to SharedPreferences
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void resetTimer() {
    stopTimer();
    setState(() {
      secondsRemaining = widget.initialDuration * 60;
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final currentTime = DateTime.now();
    final completedMinutes = widget.initialDuration - (secondsRemaining ~/ 60);

    // Save progress in SharedPreferences
    final key = 'habit_progress_${currentTime.toIso8601String()}';
    await prefs.setInt(key, completedMinutes);

    print("Progress saved: $completedMinutes minutes");
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = secondsRemaining ~/ 60;
    final seconds = secondsRemaining % 60;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}",
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: startTimer,
              icon: const Icon(CupertinoIcons.play_arrow, color: Colors.white),
              label: const Text(
                "Start",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                Get.snackbar(
                  "Habit Stopped",
                  "Timer is paused for the habit.",
                  snackPosition: SnackPosition.BOTTOM,
                );
                stopTimer();
              },
              icon: const Icon(CupertinoIcons.pause, color: Colors.white),
              label: const Text(
                "Pause",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: resetTimer,
              icon: const Icon(
                CupertinoIcons.refresh_thick,
                color: Colors.white,
              ),
              label: const Text(
                "Reset",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

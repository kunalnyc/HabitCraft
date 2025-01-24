// ignore_for_file: unnecessary_cast

import 'package:habit_tracker/Logic/habit.dart';
import 'package:hive/hive.dart';

class HabitAdapter extends TypeAdapter<Habit> {
  @override
  final int typeId = 0; // Unique type ID for the Habit model.

  @override
  Habit read(BinaryReader reader) {
    final title = reader.readString();
    final description = reader.readString();
    final color = reader.readString();
    final completedDates = (reader.readList() as List).cast<DateTime>();
    return Habit(
      title: title,
      description: description,
      color: color,
      completedDates: completedDates,
    );
  }

  @override
  void write(BinaryWriter writer, Habit obj) {
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeString(obj.color);
    writer.writeList(obj.completedDates);
  }
}

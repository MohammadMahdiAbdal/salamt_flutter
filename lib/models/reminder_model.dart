import 'package:flutter/material.dart';

class Reminder {
  String text;
  TimeOfDay time;
  bool isActive; // اضافه شد برای فعال/غیرفعال کردن یادآور

  Reminder({required this.text, required this.time, this.isActive = true});

  // برای ذخیره سازی با SharedPreferences
  Map<String, dynamic> toJson() => {
    'text': text,
    'hour': time.hour,
    'minute': time.minute,
    'isActive': isActive,
  };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    text: json['text'],
    time: TimeOfDay(hour: json['hour'], minute: json['minute']),
    isActive: json['isActive'] ?? true, // مقدار پیشفرض اگر فیلد موجود نباشد
  );
}

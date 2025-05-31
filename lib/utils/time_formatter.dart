import 'package:flutter/material.dart';

class TimeFormatter {
  /// Форматирует время в читаемый формат
  static String formatTime(TimeOfDay time, BuildContext context) {
    return time.format(context);
  }

  /// Форматирует время в строку для хранения в базе данных
  static String timeToString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  /// Парсит строку времени из базы данных в TimeOfDay
  static TimeOfDay? stringToTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;
    
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // Если не удается парсить, возвращаем null
    }
    
    return null;
  }

  /// Создает красивый формат времени с иконкой
  static Widget buildTimeChip(TimeOfDay time, BuildContext context, {Color? backgroundColor, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? Theme.of(context).primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.schedule,
            size: 14,
            color: textColor ?? Theme.of(context).primaryColor,
          ),
          const SizedBox(width: 4),
          Text(
            time.format(context),
            style: TextStyle(
              color: textColor ?? Theme.of(context).primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
} 
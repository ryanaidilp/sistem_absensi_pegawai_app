extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isToday() {
    final now = DateTime.now();
    final diff = now.difference(this).inDays;
    return diff == 0 && now.day == day;
  }

  bool isWeekend() {
    return weekday == 6 || weekday == 7;
  }

  bool isFinished() {
    return isBefore(DateTime.now());
  }

  bool isOnGoing() {
    return isAfter(DateTime.now());
  }
}

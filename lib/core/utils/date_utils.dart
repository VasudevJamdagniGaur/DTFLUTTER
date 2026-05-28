import 'package:intl/intl.dart';

/// Date helpers mirroring `src/utils/dateUtils.js` (India timezone).
class DeiteDateUtils {
  static String getDateId([DateTime? date]) {
    final d = date ?? DateTime.now();
    final ist = d.toUtc().add(const Duration(hours: 5, minutes: 30));
    return DateFormat('yyyy-MM-dd').format(ist);
  }

  static String formatDateForDisplay(dynamic dateInput) {
    DateTime date;
    if (dateInput is DateTime) {
      date = dateInput;
    } else {
      date = DateTime.parse('${dateInput}T00:00:00');
    }
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }

  static bool isToday(String dateId) => dateId == getDateId();

  static String getDateIdDaysAgo(int daysAgo) {
    final date = DateTime.now().subtract(Duration(days: daysAgo));
    return getDateId(date);
  }
}

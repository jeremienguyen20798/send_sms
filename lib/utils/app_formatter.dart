import 'package:intl/intl.dart';

class AppFormatter {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }
}

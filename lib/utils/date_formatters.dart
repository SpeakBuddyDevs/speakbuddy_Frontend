/// Utilidades para formatear fechas en español.
class DateFormatters {
  /// Formatea una fecha para mostrar en la UI.
  /// 
  /// Formato:
  /// - "Hoy • HH:mm" si es hoy
  /// - "Mañana • HH:mm" si es mañana
  /// - "DD/MM • HH:mm" si es esta semana
  /// - "DD/MM/YYYY • HH:mm" si es más lejano
  static String formatExchangeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    // Formatear hora manualmente
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';
    
    if (dateOnly == today) {
      return 'Hoy • $timeStr';
    } else if (dateOnly == tomorrow) {
      return 'Mañana • $timeStr';
    } else {
      // Calcular diferencia en días
      final diffDays = dateOnly.difference(today).inDays;
      
      if (diffDays < 7) {
        // Esta semana: mostrar día/mes
        final day = date.day.toString().padLeft(2, '0');
        final month = date.month.toString().padLeft(2, '0');
        return '$day/$month • $timeStr';
      } else {
        // Más lejano: mostrar día/mes/año
        final day = date.day.toString().padLeft(2, '0');
        final month = date.month.toString().padLeft(2, '0');
        final year = date.year.toString();
        return '$day/$month/$year • $timeStr';
      }
    }
  }
}

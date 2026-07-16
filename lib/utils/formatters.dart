class Formatters {
  static String price(double amount) => 'Rs ${amount.toStringAsFixed(0)}';
  
  static String distance(double km) => '${km.toStringAsFixed(1)} km';
  
  static String rating(double rate) => rate.toStringAsFixed(1);
  
  static String matchPercent(double? score) {
    if (score == null) return '0%';
    final percent = (score / 100 * 100).toStringAsFixed(0);
    return '$percent%';
  }
}
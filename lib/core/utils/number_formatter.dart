/// Formats large counts into compact strings, e.g. 8200 -> "8.2K", 1500000 -> "1.5M".
String formatCompactCount(int value) {
  if (value >= 1000000) {
    final m = value / 1000000;
    return '${_trim(m)}M';
  }
  if (value >= 1000) {
    final k = value / 1000;
    return '${_trim(k)}K';
  }
  return '$value';
}

String _trim(double v) {
  // One decimal place, but drop a trailing ".0".
  final s = v.toStringAsFixed(1);
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}

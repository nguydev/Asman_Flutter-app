

typedef ProfileInfoRowData = ({String label, String value});

class StringFormat {
  StringFormat._();

  static String formatSpecialty(String s) {
    final withSpace = s.replaceAll('_', ' ');
    return withSpace.isEmpty
        ? withSpace
        : withSpace[0].toUpperCase() + withSpace.substring(1);
  }

  static String formatLabel(String value) {
    return value
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }

  static String formatSelectedList(List<String> values) {
    return values.map(formatLabel).join(', ');
  }

  static String slugFromName(String name) {
    return name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '-')
        .replaceAll(RegExp(r'-+'), '-');
  }

  static String valueOrNa(String? value) {
    if (value == null || value.trim().isEmpty) return 'N/A';
    return value;
  }

  static String specialtyOrNa(String? specialty) {
    if (specialty == null || specialty.trim().isEmpty) return 'N/A';
    return formatSpecialty(specialty);
  }

  static String listOrNa(List<String>? values) {
    if (values == null || values.isEmpty) return 'N/A';
    return values.join(', ');
  }

  static bool hasText(String? value) =>
      value != null && value.trim().isNotEmpty;

  static int? parseHeight(String value) {
    final cmMatch = RegExp(r'\((\d+)\s*cm\)').firstMatch(value.trim());
    if (cmMatch != null) {
      return int.tryParse(cmMatch.group(1)!);
    }
    return int.tryParse(value.trim());
  }

  static double? parseWeight(String value) {
    final match = RegExp(r'([\d.]+)').firstMatch(value.trim());
    return match != null ? double.tryParse(match.group(1)!) : null;
  }
}

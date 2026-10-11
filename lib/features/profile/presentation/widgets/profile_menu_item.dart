import 'package:flutter/foundation.dart';

/// A single row in a profile settings section.
class ProfileMenuItem {
  final String title;
  final String subtitle;
  final String iconPath;
  final VoidCallback onTap;

  const ProfileMenuItem({
    required this.title,
    required this.iconPath,
    required this.onTap,
    this.subtitle = '',
  });
}

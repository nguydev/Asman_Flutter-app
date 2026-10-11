import 'package:flutter/material.dart';
import 'package:flutter_task/core/utils/assets.gen.dart';
import 'package:flutter_task/features/home/presentation/home_screen.dart';
import 'package:flutter_task/features/profile/presentation/profile_screen.dart';
import 'package:flutter_task/features/map/presentation/map_screen.dart';

class NavItemModel {
  final String icon;
  final String? activeIcon;
  final String? label;
  final Widget screen;

  const NavItemModel({
    required this.icon,
    this.activeIcon,
    this.label,
    required this.screen,
  });

  static List<NavItemModel> get userNavItems => _navItems;

  // ─── Bottom Nav Items ──────────────────────────────────────────────────────
  static final List<NavItemModel> _navItems = [
    NavItemModel(
      label: 'Home',
      icon: Assets.icons.home.path,
      screen: const HomeScreen(),
    ),
    NavItemModel(
      label: 'Map',
      icon: Assets.icons.map.path,
      screen: const MapScreen(),
    ),
    NavItemModel(
      label: 'Profile',
      icon: Assets.icons.profile.path,
      screen: const ProfileScreen(),
    ),
  ];
}

import 'package:flutter/material.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:flutter_task/features/bottom_nav_bar/presentation/widgets/bottom_nav_bar.dart';
import 'package:flutter_task/features/home/presentation/home_screen.dart';
import 'package:flutter_task/features/map/presentation/map_screen.dart';
import 'package:flutter_task/features/profile/presentation/profile_screen.dart';
import 'package:get/get.dart';

class MainBottomNavBar extends StatelessWidget {
  const MainBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: GetBuilder<BottomNavBarController>(
        builder: (controller) {
          final index = controller.selectedIndex;
          // Do not keep GoogleMap inside IndexedStack — on Android the
          // platform view often mounts while offstage and stays blank forever.
          return Stack(
            fit: StackFit.expand,
            children: [
              Offstage(
                offstage: index != 0,
                child: TickerMode(
                  enabled: index == 0,
                  child: const HomeScreen(),
                ),
              ),
              if (index == 1) const MapScreen(),
              Offstage(
                offstage: index != 2,
                child: TickerMode(
                  enabled: index == 2,
                  child: const ProfileScreen(),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

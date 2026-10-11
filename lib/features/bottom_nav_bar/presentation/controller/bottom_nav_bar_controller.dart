import 'package:get/get.dart';

class BottomNavBarController extends GetxController {

  static BottomNavBarController get to => Get.find();

  int selectedIndex = 0;

  void onChange(int index) {
    selectedIndex = index;
    update();
  }
}

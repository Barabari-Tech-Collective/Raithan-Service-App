import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/splash_screen_controller.dart';

class SplashScreen extends GetView<SplashScreenController> {
  SplashScreen({Key? key}) : super(key: key) {
    Get.put(SplashScreenController());
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
Center(
  child: Image.asset(
    'assets/images/logo/logo.png',
    width: screenWidth * 0.7,
    fit: BoxFit.contain,
  ),
),
          const SizedBox(height: 16),
          SizedBox(
            width: screenWidth * (5 / 6),
            child: Text(
              'Raithan_Agri_Logistic_Private_Limited'.tr, 
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
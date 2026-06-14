import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:raithan_serviceapp/Utils/app_dimensions.dart';
import 'package:raithan_serviceapp/Utils/app_style.dart';

class PinPage extends StatelessWidget {
  final TextEditingController pinController;
  final GlobalKey<FormState> formKey;
  final bool isLogin;

  const PinPage({
    super.key,
    required this.pinController,
    required this.formKey,
    this.isLogin = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double boxWidth = (constraints.maxWidth - 80) / 6;
        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppDimensions.formFieldPadding,
            horizontal: AppDimensions.formFieldPadding,
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLogin ? 'Enter PIN'.tr : 'Create PIN'.tr,
                  style: robotoBold.copyWith(color: black, fontSize: 26),
                ),
                Text(
                  isLogin
                      ? 'Enter your 4-digit PIN to sign in'.tr
                      : 'Set a 4-digit PIN to secure your account'.tr,
                  style: robotoBold.copyWith(
                      color: Colors.black45, fontSize: 12),
                ),
                const SizedBox(height: 30),
                Pinput(
                  controller: pinController,
                  length: 4,
                  obscureText: true,
                  defaultPinTheme: PinTheme(
                    width: boxWidth,
                    height: boxWidth,
                    textStyle:
                        const TextStyle(fontSize: 20, color: Colors.black),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: boxWidth,
                    height: boxWidth,
                    textStyle:
                        const TextStyle(fontSize: 20, color: Colors.black),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your PIN'.tr;
                    }
                    if (value.length != 4) {
                      return 'PIN must be 4 digits'.tr;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
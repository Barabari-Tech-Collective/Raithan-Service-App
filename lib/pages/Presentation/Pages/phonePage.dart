import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raithan_serviceapp/Utils/app_dimensions.dart';
import 'package:raithan_serviceapp/Utils/app_style.dart';
import 'package:raithan_serviceapp/Widgets/textField.dart';

class PhonePage extends StatelessWidget {
  final TextEditingController phoneController;
  final GlobalKey<FormState> formKey;

  const PhonePage({
    super.key,
    required this.phoneController,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppDimensions.formFieldPadding,
        horizontal: AppDimensions.formFieldPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Phone".tr,
            style: robotoBold.copyWith(
              color: black,
              fontSize: 26,
            ),
          ),
          Text(
            "Enter your mobile number".tr,
            style: robotoBold.copyWith(
              color: Colors.black45,
              fontSize: 12,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Form(
            key: formKey,
            child: Column(
              children: [
                CustomTextfield(
                  controller: phoneController,
                  type: TextInputType.phone,
                  label: 'Phone Number'.tr,
                  maxLength: 20,
                  isBuildCounterRequired: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a phone number'.tr;
                    }

                    // Reject letters and other symbols.
                    if (!RegExp(r'^[0-9+\-\s]+$').hasMatch(value)) {
                      return 'Please enter a valid phone number'.tr;
                    }

                    // Remove spaces and hyphens for length checking.
                    final digitsOnly =
                        value.replaceAll(RegExp(r'[^0-9]'), '');

                    if (digitsOnly.length < 10 ||
                        digitsOnly.length > 15) {
                      return 'Please enter a valid phone number'.tr;
                    }

                    return null;
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
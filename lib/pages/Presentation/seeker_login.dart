import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raithan_serviceapp/Utils/app_style.dart';
import 'package:raithan_serviceapp/controller/seeker_auth_controller.dart';

import '../../Utils/app_dimensions.dart';
import '../../Utils/storage.dart';
import '../../Utils/utils.dart';
import '../../constants/enums/custom_snackbar_status.dart';
import '../../constants/routes/route_name.dart';
import '../../constants/storage_keys.dart';
import 'Pages/phonePage.dart';

import 'package:raithan_serviceapp/constants/enums/language_enum.dart';

class SeekerLoginScreen extends StatefulWidget {
  const SeekerLoginScreen({super.key});

  @override
  State<SeekerLoginScreen> createState() => _SeekerLoginScreenState();
}

class _SeekerLoginScreenState extends State<SeekerLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _phoneFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _prefillPhone();
  }

  Future<void> _prefillPhone() async {
    final String? saved = await Storage.getValue(StorageKeys.SEEKER_PHONE);
    if (saved != null && saved.isNotEmpty) {
      setState(() => _phoneController.text = saved);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _continueAsSeeker(BuildContext context) async {
    if (!(_phoneFormKey.currentState?.validate() ?? false)) {
      Utils.showSnackbar(
        'Almost There!'.tr,
        'Please enter a valid phone number'.tr,
        CustomSnackbarStatus.warning,
      );
      return;
    }

Utils.showBackDropLoading(context);

try {
  print('====================');
  print('Before Get.put');

  final SeekerAuthController controller =
      Get.put(SeekerAuthController());

  print('After Get.put');

  await controller.loginOrRegister(
    phone: _phoneController.text,
  );

  print('loginOrRegister finished');

  Navigator.of(context).pop();

  // TODO Part 12: replace with RouteName.seekerHome
  Get.offAllNamed(RouteName.provider_home);
} catch (e, stackTrace) {
  print('====================');
  print('ERROR IN _continueAsSeeker');
  print(e);
  print(stackTrace);
  print('====================');

  Navigator.of(context).pop();

  Utils.showSnackbar(
    'Oops !'.tr,
    'Something went wrong. Please try again.'.tr,
    CustomSnackbarStatus.error,
  );
}
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: max(0, screenHeight - MediaQuery.of(context).padding.top),
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.all(AppDimensions.formFieldPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
    children: [
  Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        'Raithan'.tr,
        style: robotoBold.copyWith(
          color: white,
          fontSize: 32,
        ),
      ),
      PopupMenuButton(
        icon: const Icon(
          Icons.more_vert,
          color: white,
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () {
              Get.updateLocale(
                Locale(LanguageEnum.hi.name),
              );
              Storage.saveValue(
                StorageKeys.LANGUAGE,
                LanguageEnum.hi.name,
              );
            },
            child: const Text("हिन्दी"),
          ),
          PopupMenuItem(
            onTap: () {
              Get.updateLocale(
                Locale(LanguageEnum.en.name),
              );
              Storage.saveValue(
                StorageKeys.LANGUAGE,
                LanguageEnum.en.name,
              );
            },
            child: const Text("English"),
          ),
          PopupMenuItem(
            onTap: () {
              Get.updateLocale(
                Locale(LanguageEnum.te.name),
              );
              Storage.saveValue(
                StorageKeys.LANGUAGE,
                LanguageEnum.te.name,
              );
            },
            child: const Text("తెలుగు"),
          ),
        ],
      ),
    ],
  ),

  const SizedBox(height: 8),

  Text(
    'Enter your phone number to find services near you'.tr,
                      style: robotoBold.copyWith(
                        color: white,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 8),

                    const SizedBox(height: 32),
                    Container(
                      decoration: const BoxDecoration(
                        color: Color(0xFFF8F4F4),
                        borderRadius: BorderRadius.all(Radius.circular(25)),
                      ),
                      child: PhonePage(
                        phoneController: _phoneController,
                        formKey: _phoneFormKey,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Primary: seeker
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => _continueAsSeeker(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Find Services'.tr,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Secondary: provider
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: () => Get.toNamed(RouteName.login),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'I am a Service Provider'.tr,
                          style: robotoNormal.copyWith(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
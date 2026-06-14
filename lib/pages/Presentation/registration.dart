import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raithan_serviceapp/Utils/app_style.dart';
import 'package:raithan_serviceapp/controller/auth_controller.dart';

import '../../Utils/app_dimensions.dart';
import '../../Utils/utils.dart';
import '../../constants/enums/custom_snackbar_status.dart';
import '../../constants/routes/route_name.dart';
import 'Pages/phonePage.dart';
import 'Pages/pinPage.dart';
import 'login.dart'; // reuses StepItem

class Registration extends StatefulWidget {
  const Registration({super.key});

  @override
  State<Registration> createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  int currentPhase = 0;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final GlobalKey<FormState> _phoneFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _pinFormKey = GlobalKey<FormState>();
  final GlobalKey _containerKeyHero = GlobalKey();
  final GlobalKey _containerKeyNextButton = GlobalKey();
  double containerHeroHeight = 0;
  double containerNextButtonHeight = 0;

  void _submitPhone() {
    if (_phoneFormKey.currentState?.validate() ?? false) {
      setState(() => currentPhase = 1);
    } else {
      Utils.showSnackbar(
        'Almost There!',
        'Please write valid Phone Number',
        CustomSnackbarStatus.warning,
      );
    }
  }

  void _submitPin(BuildContext context) async {
    if (_pinFormKey.currentState?.validate() ?? false) {
      Utils.showBackDropLoading(context);
      try {
        final AuthController authController = Get.find();
        await authController.register(
          phone: _phoneController.text,
          pin: _pinController.text,
        );
        Navigator.of(context).pop();
        Utils.showSnackbar(
            'Yeah !', 'Registration successful!', CustomSnackbarStatus.success);
        Get.offAllNamed(RouteName.profile);
      } catch (e) {
        Navigator.of(context).pop();
        if (e is Exception) {
          Utils.handleException(e);
        } else {
          Utils.showSnackbar(
            'Oops !',
            'Something went wrong. Please try again.',
            CustomSnackbarStatus.error,
          );
        }
      }
    } else {
      Utils.showSnackbar(
        'Almost There!',
        'Please enter your PIN',
        CustomSnackbarStatus.warning,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox renderBoxHero =
          _containerKeyHero.currentContext?.findRenderObject() as RenderBox;
      final RenderBox renderBoxNextButton =
          _containerKeyNextButton.currentContext?.findRenderObject()
              as RenderBox;
      setState(() {
        containerHeroHeight = renderBoxHero.size.height;
        containerNextButtonHeight = renderBoxNextButton.size.height;
      });
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              key: _containerKeyHero,
              padding: const EdgeInsets.only(
                top: AppDimensions.auth_screen_top_padding,
                left: AppDimensions.auth_screen_padding,
                right: AppDimensions.auth_screen_padding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome'.tr,
                    style: robotoNormal.copyWith(
                      color: Colors.white38,
                      fontSize: AppDimensions.largeFontSize,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Sign Up'.tr,
                    style: robotoBold.copyWith(
                      color: white,
                      fontSize: AppDimensions.extraLargeFontSize * 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      text: 'Already Registered? '.tr,
                      style: robotoNormal.copyWith(
                        color: white,
                        fontSize: AppDimensions.regularFontSize,
                      ),
                      children: [
                        TextSpan(
                          text: 'Sign In'.tr,
                          style: robotoBold.copyWith(
                            color: Colors.blue,
                            fontSize: AppDimensions.regularFontSize,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      StepItem(
                        stepNumber: 1,
                        label: 'Phone'.tr,
                        currentPhase: currentPhase,
                        crossAxisAlignment: CrossAxisAlignment.start,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 25.0),
                          child: Container(
                            height: 2,
                            color: currentPhase >= 1
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ),
                      StepItem(
                        stepNumber: 2,
                        label: 'PIN'.tr,
                        currentPhase: currentPhase,
                        crossAxisAlignment: CrossAxisAlignment.end,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              constraints: BoxConstraints(
                minHeight: screenHeight -
                    containerHeroHeight -
                    AppDimensions.auth_screen_top_padding -
                    containerNextButtonHeight -
                    30,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F4F4),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: currentPhase == 0
                  ? PhonePage(
                      phoneController: _phoneController,
                      formKey: _phoneFormKey,
                    )
                  : PinPage(
                      pinController: _pinController,
                      formKey: _pinFormKey,
                      isLogin: false,
                    ),
            ),
            Container(
              key: _containerKeyNextButton,
              padding: EdgeInsets.only(
                left: AppDimensions.formFieldPadding,
                right: AppDimensions.formFieldPadding,
                bottom: AppDimensions.formFieldPadding,
              ),
              color: white,
              child: Row(
                children: [
                  if (currentPhase == 1)
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            currentPhase = 0;
                            _pinController.clear();
                          });
                        },
                        icon: const Icon(Icons.arrow_back),
                        color: Colors.black,
                      ),
                    ),
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextButton(
                        onPressed: () {
                          if (currentPhase == 0) {
                            _submitPhone();
                          } else {
                            _submitPin(context);
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Next'.tr,
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Icon(Icons.arrow_forward,
                                size: 22, color: Colors.black),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
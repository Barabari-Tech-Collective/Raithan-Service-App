import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raithan_serviceapp/Utils/app_style.dart';
import 'package:raithan_serviceapp/controller/auth_controller.dart';
import 'package:raithan_serviceapp/pages/Presentation/registration.dart';

import '../../Utils/app_dimensions.dart';
import '../../Utils/utils.dart';
import '../../constants/enums/custom_snackbar_status.dart';
import 'Pages/phonePage.dart';
import 'Pages/pinPage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
        final String status = await authController.login(
          phone: _phoneController.text,
          pin: _pinController.text,
        );
        Navigator.of(context).pop();
        authController.navigateBasedOnStatus(status);
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
                    'Sign In'.tr,
                    style: robotoBold.copyWith(
                      color: white,
                      fontSize: AppDimensions.extraLargeFontSize * 1.5,
                    ),
                  ),
                  const SizedBox(height: 5),
                  RichText(
                    text: TextSpan(
                      text: 'New User? '.tr,
                      style: robotoNormal.copyWith(
                        color: white,
                        fontSize: AppDimensions.regularFontSize,
                      ),
                      children: [
                        TextSpan(
                          text: ' ${'Sign Up'.tr}',
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
                                  builder: (context) => const Registration(),
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
                      isLogin: true,
                    ),
            ),
            Container(
              key: _containerKeyNextButton,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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

class StepItem extends StatelessWidget {
  final int stepNumber;
  final String label;
  final int currentPhase;
  final CrossAxisAlignment crossAxisAlignment;

  const StepItem({
    super.key,
    required this.stepNumber,
    required this.label,
    required this.currentPhase,
    required this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          CircleAvatar(
            radius: 10,
            backgroundColor:
                currentPhase <= stepNumber - 1 ? black : Colors.green,
            child: currentPhase > stepNumber - 1
                ? const Icon(Icons.check, color: Colors.white, size: 10)
                : currentPhase == stepNumber - 1
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
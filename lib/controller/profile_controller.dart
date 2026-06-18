import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Utils/cloudinary_utils.dart';
import '../Utils/storage.dart';
import '../Utils/utils.dart';
import '../constants/cloudinary_config.dart';
import '../constants/enums/custom_snackbar_status.dart';
import '../constants/routes/route_name.dart';
import '../constants/storage_keys.dart';

class ProfileController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  RxBool isEditAllowed = true.obs;
  RxBool isLoading = false.obs;
  RxBool savingProfileDetails = false.obs;
  RxString profileImage = ''.obs;
  RxBool isImageUpdated = false.obs;

  final GlobalKey<FormState> profileDetailsFormKey = GlobalKey<FormState>();
  final ScrollController scrollController = ScrollController();

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  final FocusNode firstNameFocusNode = FocusNode();
  final FocusNode lastNameFocusNode = FocusNode();
  final FocusNode dobFocusNode = FocusNode();
  final FocusNode genderFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  @override
  void onClose() {
    scrollController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    genderController.dispose();
    firstNameFocusNode.dispose();
    lastNameFocusNode.dispose();
    dobFocusNode.dispose();
    genderFocusNode.dispose();
    super.onClose();
  }

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadProfile() async {
    final String? userId = await Storage.getValue(StorageKeys.USER_ID);
    if (userId == null) return;

    isLoading.value = true;
    try {
      final data = await supabase
          .rpc('get_provider_full', params: {'p_user_id': userId});

      if (data == null) return;

      // ⚠️ Update these field names after running the SQL column check
      firstNameController.text = data['first_name'] ?? '';
      lastNameController.text  = data['last_name']  ?? '';
      dobController.text       = data['year_of_birth']?.toString() ?? '';
      genderController.text    = data['gender'] ?? '';

      final String? imageUrl = data['profile_image_url'];
      if (imageUrl != null && imageUrl.isNotEmpty) {
        profileImage.value  = imageUrl;
        isEditAllowed.value = false;
      }
    } catch (_) {
      // No profile yet — stay in edit mode
    } finally {
      isLoading.value = false;
    }
  }

  // ── Image picker ──────────────────────────────────────────────────────────

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;

    await Utils.clearImageCache(profileImage.value);
    profileImage.value   = picked.path;
    isImageUpdated.value = true;
  }

  void allowEditProfileDetails() {
    isEditAllowed.value = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.linear,
      );
    });
  }

  // ── Year picker ───────────────────────────────────────────────────────────

  Future<void> showYearPicker(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    DateTime selectedDate = DateTime(
      int.tryParse(dobController.text) ?? (currentDate.year - 25),
    );

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        child: SizedBox(
          height: 300,
          child: Material(
            color: Colors.transparent,
            child: YearPicker(
              firstDate: DateTime(1900),
              lastDate: DateTime(currentDate.year - 18),
              selectedDate: selectedDate,
              onChanged: (DateTime date) {
                dobController.text = date.year.toString();
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  // ── Save ──────────────────────────────────────────────────────────────────

  Future<void> saveUserProfilDetails(BuildContext context) async {
    if (!(profileDetailsFormKey.currentState?.validate() ?? false)) {
      Utils.showSnackbar(
        'Almost There!',
        'Please fill in all required fields'.tr,
        CustomSnackbarStatus.warning,
      );
      return;
    }

    if (profileImage.value.isEmpty) {
      Utils.showSnackbar(
        'Almost There!',
        'Please select a profile photo'.tr,
        CustomSnackbarStatus.warning,
      );
      return;
    }

    Future.delayed(const Duration(milliseconds: 100), () {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.linear,
      );
    });

    Utils.showBackDropLoading(context);
    savingProfileDetails.value = true;

    try {
      final String? userId = await Storage.getValue(StorageKeys.USER_ID);
      if (userId == null) throw Exception('User not found');

      String imageUrl = profileImage.value;
      if (isImageUpdated.value) {
        final result = await CloudinaryUtils.uploadToCloudinary(
          File(profileImage.value),
          'raithan/profile-pictures',
          CloudinaryConfig.publicPreset,
        );
        imageUrl = result['secure_url']!;
      }

      // ⚠️ Update column names here too after SQL check
      await supabase.from('provider_profiles').upsert({
        'user_id':           userId,
        'first_name':        firstNameController.text.trim(),
        'last_name':         lastNameController.text.trim(),
        'year_of_birth':     int.tryParse(dobController.text),
        'gender':            genderController.text,
        'profile_image_url': imageUrl,
        'status':            'business_pending',
      });

      await Storage.saveValue(StorageKeys.CURRENT_PHASE, 'business_pending');

      isEditAllowed.value = false;
      Navigator.of(context).pop();
      Utils.showSnackbar('Yeah !', 'Profile saved!'.tr, CustomSnackbarStatus.success);

      Get.offAllNamed(RouteName.business);
    } catch (e) {
      Navigator.of(context).pop();
      if (e is Exception) {
        Utils.handleException(e);
      } else {
        Utils.showSnackbar(
          'Oops !',
          'Failed to save profile. Please try again.'.tr,
          CustomSnackbarStatus.error,
        );
      }
    } finally {
      savingProfileDetails.value = false;
    }
  }
}
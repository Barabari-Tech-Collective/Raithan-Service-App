import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Utils/storage.dart';
import '../Utils/supabase_utils.dart';
import '../constants/storage_keys.dart';

import '../constants/routes/route_name.dart';

// imports that are to be remove only removed after complete migration to supabase
import '../network/BaseApiServices.dart';
import '../network/NetworkApiService.dart';


class AuthController extends GetxController {
  RxString userRole = ''.obs;
  RxBool activeSession = false.obs;

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> register({
    required String phone,
    required String pin,
  }) async {
    final response = await supabase.auth.signUp(
      email: toAuthEmail(phone),
      password: pin,
    );

    final user = response.user;

    if (user == null) {
      throw Exception('Registration failed');
    }

    await supabase.from('user_roles').insert({
      'user_id': user.id,
      'role': 'provider',
    });

    await supabase.from('provider_profiles').insert({
      'user_id': user.id,
      'status': 'profile_pending',
    });

    await Storage.saveValue(
      StorageKeys.USER_ID,
      user.id,
    );

    await fetchCurrentStatus();

    userRole.value = 'provider';
    activeSession.value = true;
  }

  Future<String> login({
    required String phone,
    required String pin,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: toAuthEmail(phone),
      password: pin,
    );

    final user = response.user;

    if (user == null) {
      throw Exception('Login failed');
    }

    await Storage.saveValue(
      StorageKeys.USER_ID,
      user.id,
    );

    final providerProfile = await supabase
        .from('provider_profiles')
        .select('status')
        .eq('user_id', user.id)
        .single();

    final String status = providerProfile['status'] as String;

    await Storage.saveValue(
      StorageKeys.CURRENT_PHASE,
      status,
    );

    userRole.value = 'provider';
    activeSession.value = true;

    return status;
  }

  Future<String?> fetchCurrentStatus() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final providerProfile = await supabase
        .from('provider_profiles')
        .select('status')
        .eq('user_id', user.id)
        .single();

    final String status = providerProfile['status'] as String;

    await Storage.saveValue(
      StorageKeys.CURRENT_PHASE,
      status,
    );

    return status;
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    activeSession.value = false;
    userRole.value = '';

    await Storage.removeKey(StorageKeys.USER_ID);
    await Storage.removeKey(StorageKeys.CURRENT_PHASE);
    await Storage.removeKey(StorageKeys.BUSINESS_ID);
  }

  void navigateBasedOnStatus(String status) {
  switch (status) {
    case 'profile_pending':
      Get.offAllNamed(RouteName.profile);
      break;
    case 'business_pending':
      Get.offAllNamed(RouteName.business);
      break;
    case 'verification_required':
    case 're_verification_required':
    case 'modification_required':
      Get.offAllNamed(RouteName.pendingVerification);
      break;
    case 'verified':
      Get.offAllNamed(RouteName.provider_home);
      break;
    case 'blocked':
    case 'rejected':
      logout();
      Get.offAllNamed(RouteName.login);
      Get.dialog(
        AlertDialog(
          title: Text(
            status == 'blocked'
                ? 'Account Blocked'.tr
                : 'Registration Rejected'.tr,
          ),
          content: Text(
            status == 'blocked'
                ? 'Your account has been blocked. Please contact support.'.tr
                : 'Your registration was not approved. Please contact support.'.tr,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('OK'.tr),
            ),
          ],
        ),
      );
      break;
    default:
      Get.offAllNamed(RouteName.login);
  }
}
// temporary line that is to be  removed after complete migration to supabase

final BaseApiServices baseApiServices = NetworkApiService();
}


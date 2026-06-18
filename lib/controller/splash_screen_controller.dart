import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Utils/storage.dart';
import '../constants/routes/route_name.dart';
import '../constants/storage_keys.dart';
import '../controller/auth_controller.dart';

class SplashScreenController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 3), loadNextScreen);
  }

  Future<void> loadNextScreen() async {
    final AuthController authController = Get.find();

    // ── 1. Provider: Supabase session exists ─────────────────────────────
    final session = supabase.auth.currentSession;

    if (session != null) {
      try {
        final String userId = session.user.id;
        await Storage.saveValue(StorageKeys.USER_ID,   userId);
        await Storage.saveValue(StorageKeys.USER_ROLE, 'PROVIDER');

        final profileRow = await supabase
            .from('provider_profiles')
            .select('status')
            .eq('user_id', userId)
            .single();

        final String status = profileRow['status'] as String;
        await Storage.saveValue(StorageKeys.CURRENT_PHASE, status);

        authController.userRole.value    = 'PROVIDER';
        authController.activeSession.value = true;

        authController.navigateBasedOnStatus(status);
      } catch (_) {
        await supabase.auth.signOut();
        authController.activeSession.value = false;
        Get.offAllNamed(RouteName.seekerLogin);
      }
      return;
    }

    // ── 2. Seeker: phone stored locally ──────────────────────────────────
    final String? seekerPhone = await Storage.getValue(StorageKeys.SEEKER_PHONE);

    if (seekerPhone != null && seekerPhone.isNotEmpty) {
      final String? seekerId = await Storage.getValue(StorageKeys.USER_ID);

      if (seekerId != null) {
        try {
          final row = await supabase
              .from('seekers')
              .select('id')
              .eq('id', seekerId)
              .maybeSingle();

          if (row != null) {
            // Returning seeker — skip phone entry
            // TODO Part 12: replace with RouteName.seekerHome
            Get.offAllNamed(RouteName.provider_home);
            return;
          }
        } catch (_) {}
      }

      // Row missing or error — clear stale data, ask again
      await Storage.removeKey(StorageKeys.USER_ID);
      await Storage.removeKey(StorageKeys.USER_ROLE);
      await Storage.removeKey(StorageKeys.SEEKER_PHONE);
    }

    // ── 3. No session and no stored phone → new user ──────────────────────
    Get.offAllNamed(RouteName.seekerLogin);
  }
}
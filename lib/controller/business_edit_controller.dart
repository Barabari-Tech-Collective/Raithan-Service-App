import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Utils/storage.dart';
import '../Utils/utils.dart';
import '../constants/enums/custom_snackbar_status.dart';
import '../constants/storage_keys.dart';
import 'business_controller.dart';

class BusinessEditController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  RxBool isLoading = false.obs;
  RxBool savingBusinessDetails = false.obs;

  final TextEditingController businessNameController  = TextEditingController();
  final TextEditingController pincodeController       = TextEditingController();
  final TextEditingController blockNumberController   = TextEditingController();
  final TextEditingController streetController        = TextEditingController();
  final TextEditingController areaController          = TextEditingController();
  final TextEditingController landmarkController      = TextEditingController();
  final TextEditingController cityController          = TextEditingController();
  final TextEditingController stateController         = TextEditingController();
  final TextEditingController startTimeController     = TextEditingController();
  final TextEditingController endTimeController       = TextEditingController();
  final TextEditingController businessTypeController  = TextEditingController();
  final TextEditingController mobileNumberController  = TextEditingController();

  final GlobalKey<FormState> businessDetailFormKey = GlobalKey<FormState>();
  final ScrollController scrollController = ScrollController();

  Map<String, bool> workingDays = {
    "Monday": false, "Tuesday": false, "Wednesday": false,
    "Thursday": false, "Friday": false, "Saturday": false, "Sunday": false,
  };

  @override
  void onInit() {
    super.onInit();
    // Expects Get.arguments to be the raw businesses row map
    final dynamic args = Get.arguments;
    if (args != null) _populate(args);
  }

  @override
  void onClose() {
    businessNameController.dispose();
    pincodeController.dispose();
    blockNumberController.dispose();
    streetController.dispose();
    areaController.dispose();
    landmarkController.dispose();
    cityController.dispose();
    stateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    businessTypeController.dispose();
    mobileNumberController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _populate(dynamic data) {
    businessNameController.text  = data['business_name']  ?? '';
    blockNumberController.text   = data['block_number']   ?? '';
    streetController.text        = data['street']         ?? '';
    areaController.text          = data['area']           ?? '';
    landmarkController.text      = data['landmark']       ?? '';
    cityController.text          = data['city']           ?? '';
    stateController.text         = data['state']          ?? '';
    pincodeController.text       = data['pincode']        ?? '';
    businessTypeController.text  = data['business_type']  ?? '';
    mobileNumberController.text  = data['mobile_number']  ?? '';

    final wt = data['working_time'];
    if (wt is Map) {
      startTimeController.text = wt['start'] ?? '';
      endTimeController.text   = wt['end']   ?? '';
    }

    final wd = data['working_days'];
    if (wd is Map) {
      for (final key in workingDays.keys) {
        workingDays[key] = wd[key] == true;
      }
    }
  }

  Future<void> saveBusinessDetails(BuildContext context) async {
    if (!(businessDetailFormKey.currentState?.validate() ?? false)) {
      Utils.showSnackbar('Almost There!',
          'Please write valid details'.tr, CustomSnackbarStatus.warning);
      return;
    }

    Utils.showBackDropLoading(context);
    savingBusinessDetails.value = true;

    try {
      final String? businessId = await Storage.getValue(StorageKeys.BUSINESS_ID);
      final String? userId     = await Storage.getValue(StorageKeys.USER_ID);
      if (businessId == null || userId == null) throw Exception('IDs not found');

      final Map<String, dynamic> updated = {
        'business_name': businessNameController.text.trim(),
        'business_type': businessTypeController.text.trim(),
        'pincode':       pincodeController.text.trim(),
        'block_number':  blockNumberController.text.trim(),
        'street':        streetController.text.trim(),
        'area':          areaController.text.trim(),
        'landmark':      landmarkController.text.trim(),
        'city':          cityController.text.trim(),
        'state':         stateController.text.trim(),
        'mobile_number': mobileNumberController.text.trim(),
        'working_days':  workingDays,
        'working_time':  {
          'start': startTimeController.text,
          'end':   endTimeController.text,
        },
      };

      await supabase.from('businesses').update(updated).eq('id', businessId);

      // Trigger re-verification
      await supabase
          .from('provider_profiles')
          .update({'status': 're_verification_required'})
          .eq('user_id', userId);

      await Storage.saveValue(
          StorageKeys.CURRENT_PHASE, 're_verification_required');

      // Refresh the parent BusinessController's view data
      try {
        Get.find<BusinessController>()
            .setBusinessDetails({...updated, 'id': businessId, 'user_id': userId});
      } catch (_) {}

      Navigator.of(context).pop();
      Navigator.of(context).pop();
      Utils.showSnackbar(
          'Yeah !', 'Business updated!'.tr, CustomSnackbarStatus.success);
    } catch (e) {
      Navigator.of(context).pop();
      if (e is Exception) {
        Utils.handleException(e);
      } else {
        Utils.showSnackbar('Oops !',
            'Failed to update business. Please try again.'.tr,
            CustomSnackbarStatus.error);
      }
    } finally {
      savingBusinessDetails.value = false;
    }
  }
}
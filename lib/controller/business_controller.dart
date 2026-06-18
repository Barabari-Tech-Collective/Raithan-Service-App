import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Utils/geo_position.dart';
import '../Utils/storage.dart';
import '../Utils/utils.dart';
import '../constants/enums/custom_snackbar_status.dart';
import '../constants/routes/route_name.dart';
import '../constants/storage_keys.dart';

class BusinessController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  RxBool isLoading = false.obs;
  RxBool savingBusinessDetails = false.obs;
  RxBool isCreateMode = false.obs; // true when no business exists yet

  // View mode display data (mirrors old controller structure exactly)
  dynamic businessInfo    = {};
  dynamic businessDetails = {};
  dynamic businessAddress = {};
  dynamic businessTime    = {};
  List<String> businessDays  = [];
  List<String> categories    = [];

  // Form fields (used in create mode)
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
    loadBusiness();
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

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadBusiness() async {
    final String? userId = await Storage.getValue(StorageKeys.USER_ID);
    if (userId == null) return;

    isLoading.value = true;
    try {
      final data = await supabase
          .from('businesses')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data == null) {
        isCreateMode.value = true;
        return;
      }

      await Storage.saveValue(StorageKeys.BUSINESS_ID, data['id'] as String);
      setBusinessDetails(data);
      isCreateMode.value = false;
    } catch (_) {
      isCreateMode.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  // Kept public so BusinessEditController can refresh the view after an edit
  void setBusinessDetails(dynamic data) {
    try {
      businessInfo = data;

      businessDetails = {
        'Business Name': data['business_name'],
        'Business Type': data['business_type'],
      };

      businessAddress = {
        'Block Number': data['block_number'],
        'Street':       data['street'],
        'Area':         data['area'],
        'Landmark':     data['landmark'],
        'City':         data['city'],
        'State':        data['state'],
        'Pincode':      data['pincode'],
      };

      final wt = data['working_time'];
      businessTime = {
        'Start Time': wt is Map ? wt['start'] : '',
        'End Time':   wt is Map ? wt['end']   : '',
      };

      final wd = data['working_days'];
      if (wd is Map) {
        businessDays = wd.entries
            .where((e) => e.value == true)
            .map((e) => e.key.toString())
            .toList();
      }

      final cats = data['categories'];
      if (cats is List && cats.isNotEmpty) {
        categories = List<String>.from(cats);
      } else {
        categories = [
          'No products have been added yet,'.tr,
          'so no categories are available.'.tr,
        ];
      }
    } catch (_) {}
  }

  // ── Create (first-time submission) ────────────────────────────────────────

  Future<void> saveBusinessDetails(BuildContext context) async {
    if (!(businessDetailFormKey.currentState?.validate() ?? false)) {
      Utils.showSnackbar('Almost There!',
          'Please fill in all required fields'.tr, CustomSnackbarStatus.warning);
      return;
    }

    Utils.showBackDropLoading(context);
    savingBusinessDetails.value = true;

    Position? position;
    try {
      position = await GeoPoistion.determinePosition();
    } catch (_) {
      Navigator.of(context).pop();
      Utils.showSnackbar('Almost There!',
          'Please allow location permission'.tr, CustomSnackbarStatus.warning);
      savingBusinessDetails.value = false;
      return;
    }

    try {
      final String? userId = await Storage.getValue(StorageKeys.USER_ID);
      if (userId == null) throw Exception('User not found');

      // PostGIS format: POINT(longitude latitude)
      final String locationStr =
          'SRID=4326;POINT(${position.longitude} ${position.latitude})';

      final List<Map<String, dynamic>> inserted = await supabase
          .from('businesses')
          .insert({
            'user_id':       userId,
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
            'location': locationStr,
          })
          .select('id');

      final String businessId = inserted.first['id'] as String;
      await Storage.saveValue(StorageKeys.BUSINESS_ID, businessId);

      // Advance provider status to verification_required
      await supabase
          .from('provider_profiles')
          .update({'status': 'verification_required'})
          .eq('user_id', userId);

      await Storage.saveValue(StorageKeys.CURRENT_PHASE, 'verification_required');

      Navigator.of(context).pop();
      Utils.showSnackbar(
          'Yeah !', 'Business registered!'.tr, CustomSnackbarStatus.success);

      Get.offAllNamed(RouteName.pendingVerification);
    } catch (e) {
      Navigator.of(context).pop();
      if (e is Exception) {
        Utils.handleException(e);
      } else {
        Utils.showSnackbar('Oops !',
            'Failed to save business. Please try again.'.tr,
            CustomSnackbarStatus.error);
      }
    } finally {
      savingBusinessDetails.value = false;
    }
  }

  // ── Update GPS location (existing business) ───────────────────────────────

  void askUpdateLocationConfirmation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text('Update Location'.tr),
        content: Text('updateLocationConfirmationText'.tr),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'.tr)),
          TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'.tr)),
        ],
      ),
    ).then((result) {
      if (result == true) updateBusinessLocation(context);
    });
  }

  void updateBusinessLocation(BuildContext context) async {
    if (context.mounted) Utils.showBackDropLoading(context);

    Position? position;
    try {
      position = await GeoPoistion.determinePosition();
    } catch (_) {
      Utils.showSnackbar('Almost There!',
          'Please allow location permission'.tr, CustomSnackbarStatus.warning);
      if (context.mounted) Navigator.of(context).pop();
      return;
    }

    try {
      final String? businessId = await Storage.getValue(StorageKeys.BUSINESS_ID);
      if (businessId == null) throw Exception('Business not found');

      final String locationStr =
          'SRID=4326;POINT(${position.longitude} ${position.latitude})';

      await supabase
          .from('businesses')
          .update({'location': locationStr})
          .eq('id', businessId);

      if (context.mounted) Navigator.of(context).pop();
      Utils.showSnackbar(
          'Yeah !', 'Location updated!'.tr, CustomSnackbarStatus.success);
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop();
      if (e is Exception) {
        Utils.handleException(e);
      } else {
        Utils.showSnackbar('Oops !',
            'Failed to update location. Please try again.'.tr,
            CustomSnackbarStatus.error);
      }
    }
  }
}
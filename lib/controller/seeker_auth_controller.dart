import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../Utils/storage.dart';
import '../constants/storage_keys.dart';

class SeekerAuthController extends GetxController {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String> loginOrRegister({required String phone}) async {
    print('====================');
    print('loginOrRegister START');
    print('phone = $phone');

    try {
      final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');

      final normalized = digits.length >= 10
          ? digits.substring(digits.length - 10)
          : digits;

      print('normalized = $normalized');

      print('Querying seekers table...');

      final existing = await supabase
          .from('seekers')
          .select('id')
          .eq('phone_number', normalized)
          .maybeSingle();

      print('existing = $existing');

      String seekerId;

      if (existing != null) {
        seekerId = existing['id'] as String;

        print('Existing seeker found');
        print('seekerId = $seekerId');
      } else {
        print('No seeker found');
        print('Inserting new seeker...');

        final inserted = await supabase
            .from('seekers')
            .insert({
              'phone_number': normalized,
            })
            .select('id')
            .single();

        print('inserted = $inserted');

        seekerId = inserted['id'] as String;

        print('New seeker created');
        print('seekerId = $seekerId');
      }

      print('Saving USER_ID');
      await Storage.saveValue(StorageKeys.USER_ID, seekerId);

      print('Saving USER_ROLE');
      await Storage.saveValue(StorageKeys.USER_ROLE, 'SEEKER');

      print('Saving SEEKER_PHONE');
      await Storage.saveValue(
        StorageKeys.SEEKER_PHONE,
        normalized,
      );

      print('loginOrRegister SUCCESS');
      print('====================');

      return seekerId;
    } catch (e, stackTrace) {
      print('====================');
      print('loginOrRegister ERROR');
      print(e);
      print(stackTrace);

      if (e is PostgrestException) {
        print('Postgrest message = ${e.message}');
        print('Postgrest details = ${e.details}');
        print('Postgrest hint = ${e.hint}');
        print('Postgrest code = ${e.code}');
      }

      print('====================');

      rethrow;
    }
  }

  Future<void> updateLocation({
    required double lat,
    required double lng,
  }) async {
    print('====================');
    print('updateLocation START');

    try {
      final String? seekerId =
          await Storage.getValue(StorageKeys.USER_ID);

      print('seekerId = $seekerId');

      if (seekerId == null) {
        print('No USER_ID found');
        return;
      }

      print('Updating location...');
      print('lat = $lat');
      print('lng = $lng');

      await supabase
          .from('seekers')
          .update({
            'location': 'SRID=4326;POINT($lng $lat)',
          })
          .eq('id', seekerId);

      print('updateLocation SUCCESS');
      print('====================');
    } catch (e, stackTrace) {
      print('====================');
      print('updateLocation ERROR');
      print(e);
      print(stackTrace);

      if (e is PostgrestException) {
        print('Postgrest message = ${e.message}');
        print('Postgrest details = ${e.details}');
        print('Postgrest hint = ${e.hint}');
        print('Postgrest code = ${e.code}');
      }

      print('====================');

      rethrow;
    }
  }

  Future<void> logout() async {
    print('====================');
    print('logout START');

    try {
      await Storage.removeKey(StorageKeys.USER_ID);
      await Storage.removeKey(StorageKeys.USER_ROLE);
      await Storage.removeKey(StorageKeys.SEEKER_PHONE);

      print('logout SUCCESS');
      print('====================');
    } catch (e, stackTrace) {
      print('====================');
      print('logout ERROR');
      print(e);
      print(stackTrace);
      print('====================');

      rethrow;
    }
  }
}
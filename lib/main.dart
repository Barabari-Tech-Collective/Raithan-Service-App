import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:raithan_serviceapp/Utils/storage.dart';
import 'package:raithan_serviceapp/Utils/app_style.dart';
import 'package:raithan_serviceapp/constants/enums/language_enum.dart';
import 'package:raithan_serviceapp/constants/routes/app_route.dart';
import 'package:raithan_serviceapp/constants/storage_keys.dart';
import 'package:raithan_serviceapp/constants/supabase_config.dart';
import 'package:raithan_serviceapp/controller/auth_controller.dart';
import 'package:raithan_serviceapp/getx_localization/languages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  Get.put(AuthController());

  String language =
      await Storage.getValue(StorageKeys.LANGUAGE) ?? "en";

  runApp(
    SafeArea(
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        locale: Locale(language),
        fallbackLocale: Locale(LanguageEnum.en.name),
        getPages: AppRoutes.appRoutes(),
        translations: Languages(),
        theme: ThemeData(
          fontFamily: "Poppins",
          colorScheme: ColorScheme.fromSeed(seedColor: black),
          appBarTheme: const AppBarTheme(
            backgroundColor: black,
          ),
          useMaterial3: true,
        ),
      ),
    ),
  );
}
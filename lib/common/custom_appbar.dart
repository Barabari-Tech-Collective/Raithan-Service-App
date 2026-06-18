import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:raithan_serviceapp/Utils/app_style.dart';
import 'package:raithan_serviceapp/Utils/storage.dart';
import 'package:raithan_serviceapp/constants/enums/language_enum.dart';
import 'package:raithan_serviceapp/constants/routes/route_name.dart';
import 'package:raithan_serviceapp/constants/storage_keys.dart';
import 'package:raithan_serviceapp/controller/auth_controller.dart';

PreferredSizeWidget customAppBar(
  String title,
  BuildContext context, {
  TabBar? tabBar,
  bool options = true,
}) {
  AuthController authController = Get.find();

  return AppBar(
    iconTheme: const IconThemeData(
      color: white,
    ),
    bottom: tabBar,
    title: Text(
      title,
      style: const TextStyle(color: white),
    ),
    backgroundColor: const Color.fromRGBO(18, 130, 105, 1),
    actions: [
      Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: options
            ? PopupMenuButton(
                icon: const Icon(
                  Icons.more_vert_sharp,
                  color: white,
                ),
                itemBuilder: (context) => [
                  // Profile
                  if (authController.userRole.value == "PROVIDER" &&
                      authController.activeSession.value)
                    PopupMenuItem(
                      onTap: () {
                        Get.toNamed(RouteName.profile);
                      },
                      child: Text("Profile".tr),
                    ),

                  // Business
                  if (authController.userRole.value == "PROVIDER" &&
                      authController.activeSession.value)
                    PopupMenuItem(
                      onTap: () {
                        Get.toNamed(RouteName.business);
                      },
                      child: Text("Business".tr),
                    ),

                  // Sign In
                  if (!authController.activeSession.value)
                    PopupMenuItem(
                      onTap: () {
                        Get.offAllNamed(RouteName.login);
                      },
                      child: Text("Sign In".tr),
                    ),

                  // Sign Out
                  if (authController.activeSession.value)
                    PopupMenuItem(
                      onTap: () async {
                        await Storage.removeAll();
                        authController.userRole.value = "SEEKER";
                        authController.activeSession.value = false;
                        Get.offAllNamed(RouteName.provider_home);
                      },
                      child: Text("Sign Out".tr),
                    ),

                  // Hindi
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

                  // English
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

                  // Telugu
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

                  // Debug option
                  PopupMenuItem(
                    onTap: () async {
                      await Storage.removeAll();
                      print("Local storage cleared");
                    },
                    child: const Text("Clear Local Data"),
                  ),
                ],
              )
            : const SizedBox(),
      ),
    ],
  );
}
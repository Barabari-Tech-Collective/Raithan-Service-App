import 'package:get/get.dart';
import 'package:raithan_serviceapp/constants/routes/route_name.dart';
import 'package:raithan_serviceapp/pages/Presentation/Pages/business.dart';
import 'package:raithan_serviceapp/pages/Presentation/Pages/business_edit.dart';
import 'package:raithan_serviceapp/pages/Presentation/Pages/labor_edit.dart';
import 'package:raithan_serviceapp/pages/Presentation/Pages/product_edit.dart';
import 'package:raithan_serviceapp/pages/Presentation/ProductList.dart';
import 'package:raithan_serviceapp/pages/Presentation/pending_verification.dart';
import 'package:raithan_serviceapp/pages/Presentation/seeker_login.dart';
import 'package:raithan_serviceapp/pages/splash_screen.dart';

import '../../pages/Presentation/Pages/profile.dart';
import '../../pages/Presentation/Pages/provider_home.dart';
import '../../pages/Presentation/login.dart';
import '../../pages/Presentation/registration.dart';

class AppRoutes {
  static appRoutes() => [
        GetPage(name: RouteName.splashScreen,
            page: () => SplashScreen()),
        GetPage(name: RouteName.login,
            page: () => const LoginScreen()),
        GetPage(name: RouteName.registration,
            page: () => const Registration()),
        GetPage(name: RouteName.seekerLogin,
            page: () => const SeekerLoginScreen()),
        GetPage(name: RouteName.profile,
            page: () => Profile()),
        GetPage(name: RouteName.provider_home,
            page: () => ProviderHome()),
        GetPage(name: RouteName.business,
            page: () => Business()),
        GetPage(name: RouteName.businessEdit,
            page: () => BusinessEdit()),
        GetPage(name: RouteName.products,
            page: () => ProductList()),
        GetPage(name: RouteName.editLaborDetails,
            page: () => LaborEdit()),
        GetPage(name: RouteName.editProductDetails,
            page: () => ProductEdit()),
        GetPage(name: RouteName.pendingVerification,
            page: () => const PendingVerificationPage()),
      ];
}
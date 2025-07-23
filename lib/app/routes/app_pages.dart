import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import '../module/auth/get_started/get_started_view.dart';
import '../module/auth/login/login_binding.dart';
import '../module/auth/login/login_view.dart';
import '../module/auth/otp/otp_view.dart';
import '../module/auth/profile_completion/profil_completion_binding.dart';
import '../module/auth/profile_completion/profile_completion_view.dart';
import '../module/auth/register/register_binding.dart';
import '../module/auth/register/register_screen.dart';
import '../module/driver_preferences/driver_preferences_binding.dart';
import '../module/driver_preferences/driver_preferences_screen.dart';
import '../module/earnings_history/earnings_history_binding.dart';
import '../module/earnings_history/earnings_history_view.dart';
import '../module/home/home_binding.dart';
import '../module/home/home_screen.dart';
import '../module/profile/profile_binding.dart';
import '../module/profile/profile_view.dart';
import '../module/splash/splash_screen.dart';

part 'app_routes.dart';

class AppPages {
  static const initial = Routes.splash;

  static final routes = [
    GetPage(name: Routes.splash, page: () => SplashScreen()),
    GetPage(
        name: Routes.getStarted,
        page: () => GetStartedScreen(),
    ),
    GetPage(
      name: Routes.login,
      page: () => LoginView(),
      binding: LoginBinding(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    ),
    GetPage(name: Routes.otp, page: () => OtpView(), binding: LoginBinding(),),
    GetPage(
      name: Routes.profileCompletion,
      page: () => ProfileCompletionView(),
      binding: ProfileCompletionBinding(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    ),
    GetPage(
      name: Routes.register,
      page: () => RegisterScreen(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.leftToRight,
    ),
    GetPage(name: Routes.driverPreferences, page: () => const DriverPreferencesScreen(), binding: DriverPreferencesBinding(), transition: Transition.leftToRight),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.earningsHistory,
      page: () => const EarningsHistoryView(),
      binding: EarningsHistoryBinding(),
    ),
  ];
}
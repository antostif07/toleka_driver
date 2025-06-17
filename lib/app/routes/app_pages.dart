import 'package:get/get.dart';

import '../module/active_ride/active_ride_binding.dart';
import '../module/active_ride/active_ride_view.dart';
import '../module/earnings_history/earnings_history_binding.dart';
import '../module/earnings_history/earnings_history_view.dart';
import '../module/home/home_binding.dart';
import '../module/home/home_screen.dart';
import '../module/login/login_binding.dart';
import '../module/login/login_view.dart';
import '../module/profile/profile_binding.dart';
import '../module/profile/profile_view.dart';
import '../module/ride_requests/ride_requests_binding.dart';
import '../module/ride_requests/ride_requests_view.dart';
import '../module/splash/splash_screen.dart';

part 'app_routes.dart';

class AppPages {
  // L'authentification sera la première étape pour un chauffeur
  static const INITIAL = Routes.login; // Temporairement, puis Routes.AUTH;

  static final routes = [
    GetPage(name: Routes.SPLASH, page: () => SplashScreen()),
    GetPage(
      name: Routes.login,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.rideRequests,
      page: () => const RideRequestsView(),
      binding: RideRequestsBinding(),
    ),
    GetPage(
      name: Routes.activeRide,
      page: () => const ActiveRideView(),
      binding: ActiveRideBinding(),
    ),
    GetPage(
      name: Routes.earningsHistory,
      page: () => const EarningsHistoryView(),
      binding: EarningsHistoryBinding(),
    ),
  ];
}
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:toleka_driver/app/module/home/widgets/driver_prefs.dart';
import 'package:toleka_driver/app/module/home/widgets/driver_stats.dart';
import 'package:toleka_driver/app/module/home/widgets/finding_rides_requests_widget.dart';
import 'package:toleka_driver/app/module/home/widgets/help_and_support_widget.dart';
import 'package:toleka_driver/app/module/home/widgets/weekly_challenges_widget.dart';
import 'package:toleka_driver/app/services/auth_services.dart';
import '../../services/driver_map_service.dart';
import 'home_controller.dart';
import 'widgets/panel_clipper.dart';
import 'widgets/status_banner_widget.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  static const double panelMinHeight = 350.0;

  // Ajoutez des constantes pour la taille du bouton pour une gestion facile
  static const double buttonWidth = 180.0;
  static const double buttonHeight = 65.0;

  @override
  Widget build(BuildContext context) {
    final DriverMapService mapService = Get.find();
    final screenSize = MediaQuery.of(context).size;
    final panelMaxHeight = screenSize.height * 0.8;

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          MapWidget(
            onMapCreated: mapService.onMapCreated,
            cameraOptions: CameraOptions(
              center: Point(coordinates: Position(-74.0060, 40.7128)),
              zoom: 12.0,
              padding: MbxEdgeInsets(
                top: 0, left: 0, right: 0,
                // On pousse le centre vers le haut pour compenser le panel
                bottom: panelMinHeight / 2,
              ),
            ),
            styleUri: MapboxStyles.LIGHT,
          ),
          SlidingUpPanel(
            boxShadow: const <BoxShadow>[BoxShadow(blurRadius: 1.0, color: Color.fromRGBO(0, 0, 0, 0.05))],
            minHeight: panelMinHeight,
            maxHeight: panelMaxHeight,
            // Connecte la position du panel au contrôleur
            onPanelSlide: (position) => controller.updatePanelPosition(position),
            color: Colors.transparent,
            // Le body ici est vide car la carte est déjà dans le Stack
            body: Container(),
            parallaxEnabled: true,
            // Le contenu du panel qui est clippé
            panel: ClipPath(
              clipper: PanelClipper(
                notchDepth: buttonHeight - 12,
                notchWidth: buttonWidth + 36,
              ),
              child: Container(
                color: Colors.white, // Ou la couleur de votre panel
                child: Obx(() {
                  // Le Obx reconstruit l'intérieur du panel quand le statut change
                  return controller.isOnline.value
                      ? _buildOnlinePanel(context)
                      : _buildOfflinePanel(context);
                }),
              ),
            ),
          ),
          Obx(() {
            // Calcule la position verticale du bouton de manière réactive
            final double topWhenCollapsed = screenSize.height - panelMinHeight - (buttonHeight / 2) + 15;
            final double topWhenExpanded = screenSize.height - panelMaxHeight - (buttonHeight / 2) + 15;

            // lerpDouble interpole entre les deux positions
            final double buttonTopPosition = lerpDouble(
              topWhenCollapsed,
              topWhenExpanded,
              controller.panelPosition.value,
            )!;

            return Positioned(
              top: buttonTopPosition,
              child: SizedBox(
                width: buttonWidth,
                height: buttonHeight,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.toggleOnlineStatus,
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    backgroundColor: controller.isOnline.value ? Colors.red : Colors.green,
                    disabledBackgroundColor: controller.isOnline.value
                        ? Colors.red.withAlpha((0.5 * 255).toInt())
                        : Colors.green.withAlpha((0.5 * 255).toInt()),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                    width: 28, // Taille de l'indicateur
                    height: 28,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3.0, // Épaisseur du trait
                    ),
                  )
                      : Text(
                    controller.isOnline.value ? 'Passez Hors Ligne' : 'Passez En Ligne',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            );
          }),
          // 4. AUTRES BOUTONS FLOTTANTS (sur la carte)
          Positioned(
            top: 50,
            left: 20,
            child: FloatingActionButton(
              heroTag: null,
              onPressed: () {},
              backgroundColor: Colors.white,
              mini: true,
              child: const Icon(Icons.menu, color: Colors.black),
            ),
          ),
          Obx(() {
            return controller.panelPosition.value > 0.0 ? SizedBox.shrink() : Positioned(
              bottom: panelMinHeight + 80,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.white,
                child: const Icon(Icons.my_location, color: Colors.black),
              ),
            );
          }),
          Obx(() {
            return controller.panelPosition.value > 0.0 ? SizedBox.shrink() : Positioned(
              bottom: panelMinHeight + 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: Colors.white,
                child: const Icon(Icons.search, color: Colors.black),
              ),
            );
          }),
        ],
      )
    );
  }

  Widget _buildOfflinePanel(BuildContext context) {
    return _buildPanelContent(context);
  }

  Widget _buildOnlinePanel(BuildContext context) {
    return _buildPanelContent(context);
  }

  /// Le contenu principal du panel, avec la logique des onglets.
  Widget _buildPanelContent(BuildContext context) {
    final HomeController controller = Get.find();

    return Column(
      children: [
        // La barre d'onglets
        _buildDriveAndEarningsTabs(context),

        const Divider(height: 1, thickness: 1),

        Expanded(
          child: Obx(
                () => IndexedStack(
              index: controller.selectedTabIndex.value,
              children: [
                _buildDriveTabContent(context),    // Index 0
                _buildEarningsTabContent(context), // Index 1
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDriveAndEarningsTabs(BuildContext context) {
    return SizedBox(
      height: 60, // Hauteur fixe pour la zone des onglets
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTabButton(context, text: 'Courses', icon: Icons.drive_eta_rounded, index: 0),
          _buildTabButton(context, text: 'Gains', icon: Icons.attach_money, index: 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, {required String text, required IconData icon, required int index}) {
    final HomeController controller = Get.find();

    return Obx(() {
      final bool isSelected = controller.selectedTabIndex.value == index;
      final Color activeColor = Colors.black; // Utilise la couleur primaire du thème
      final Color inactiveColor = Colors.grey;

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: InkWell(
          onTap: () => controller.changeTabIndex(index),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? activeColor : inactiveColor, size: 32,),
              const SizedBox(height: 4),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12.0,
                  color: isSelected ? activeColor : inactiveColor,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// Contenu de l'onglet "Drive".
  Widget _buildDriveTabContent(BuildContext context) {
    final AuthService authService = Get.find();

    return SingleChildScrollView(
      child: Column(
        children: [
          Obx(() {
            if(authService.currentDriver!.isApproved == true) {
              return SizedBox.shrink();
            } else {
              return StatusBannerWidget(
                message: 'Nous avons reçu votre soumission,\nvérifiez le statut de la vérification',
                onTap: () {
                  print("homescreen : ${authService.driver.value?.isApproved}");
                },
              );
            }
          }),
          Obx(() {
            if(controller.isOnline.value) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FindingRidesWidget(),
                  const DriverPrefs(),
                  const WeeklyChallengesWidget(),
                ],
              );
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const WeeklyChallengesWidget(),
                  const DriverStats(),
                  const DriverPrefs(),
                ],
              );
            }
          }),
          HelpAndSupportWidget(),
        ],
      ),
    );
  }

  /// Contenu de l'onglet "Earnings" (pour l'instant, un placeholder).
  Widget _buildEarningsTabContent(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.show_chart, size: 50, color: Colors.grey),
          SizedBox(height: 16),
          Text("Les statistiques de gains apparaîtront ici", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
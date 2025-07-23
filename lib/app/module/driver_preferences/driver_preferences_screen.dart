import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'driver_preferences_controller.dart';

class DriverPreferencesScreen extends StatelessWidget {
  const DriverPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get.put() injecte le contrôleur. Si vous utilisez des Bindings, ce sera Get.find()
    final DriverPreferencesController controller = Get.put(DriverPreferencesController());
    final Color activeColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Préférences de conduite',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.0),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          // Le bouton 'Réinitialiser' n'est visible que si des changements ont été faits
          Obx(() {
            if (controller.isDirty.value) {
              return TextButton(
                onPressed: controller.resetPreferences,
                child: Text(
                  'Réinitialiser',
                  style: TextStyle(color: activeColor),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
        ],
      ),
      backgroundColor: Colors.white,

      // Le bouton 'Enregistrer' est placé en bas de l'écran
      bottomNavigationBar: Obx(() {
        final bool isEnabled = controller.isDirty.value && !controller.isSaving.value;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: isEnabled ? controller.savePreferences : null,
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: Colors.grey.shade300,
            ),
            child: controller.isSaving.value
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
            )
                : const Text(
              'Enregistrer',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }),

      body: Obx(() {
        final prefs = controller.currentPreferences.value;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSwitchRow(
              title: 'Accepter l\'argent liquide',
              value: prefs.acceptsCash,
              onChanged: (newValue) {
                controller.updatePreference(prefs.copyWith(acceptsCash: newValue));
              },
            ),
            const Divider(),
            _buildSwitchRow(
              title: 'Auto-accepter les courses',
              value: prefs.autoAcceptTrips,
              onChanged: (newValue) {
                controller.updatePreference(prefs.copyWith(autoAcceptTrips: newValue));
              },
            ),
            const Divider(),
            _buildSwitchRow(
              title: 'Exclure les passagers mal notés',
              subtitle: 'Ne pas montrer les demandes de passagers avec de mauvaises notes.',
              value: prefs.excludeLowRatedRiders,
              onChanged: (newValue) {
                controller.updatePreference(prefs.copyWith(excludeLowRatedRiders: newValue));
              },
            ),
            const Divider(),
            _buildSwitchRow(
              title: 'Courses Longue Distance',
              subtitle: 'Montrer les courses de plus de 45min.',
              value: prefs.allowLongDistanceTrips,
              onChanged: (newValue) {
                controller.updatePreference(prefs.copyWith(allowLongDistanceTrips: newValue));
              },
            ),
          ],
        );
      }),
    );
  }

  // Méthode d'aide pour construire une ligne avec un interrupteur
  Widget _buildSwitchRow({required String title, String? subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey.shade600)) : null,
      value: value,
      onChanged: onChanged,
    );
  }
}
// lib/app/modules/active_ride/active_ride_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'active_ride_controller.dart';
// MapboxMap n'est pas directement dans cette vue mais peut être si vous affichez la carte ici aussi
// import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class ActiveRideView extends GetView<ActiveRideController> {
  const ActiveRideView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text('Course vers ${controller.activeRide.value.destinationAddress}')),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final ride = controller.activeRide.value;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('De: ${ride.pickupAddress}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('À: ${ride.destinationAddress}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('Prix Estimé: ${ride.estimatedPrice.toStringAsFixed(0)} CFA', style: const TextStyle(fontSize: 16, color: Colors.green)),
                      Text('Statut Actuel: ${ride.status.capitalizeFirst}', style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Boutons d'action basés sur le statut (simplifié)
              if (ride.status == 'accepted')
                ElevatedButton.icon(
                  onPressed: () => controller.updateRideStatus('picked_up'),
                  icon: const Icon(Icons.person_pin_circle),
                  label: const Text('Arrivé au point de départ'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                )
              else if (ride.status == 'picked_up')
                ElevatedButton.icon(
                  onPressed: () => controller.updateRideStatus('started'),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Démarrer la course'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                )
              else if (ride.status == 'started')
                  ElevatedButton.icon(
                    onPressed: () => controller.updateRideStatus('completed'),
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Terminer la course'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  )
                else
                  const Text('Statut de course non géré par les boutons.', textAlign: TextAlign.center),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Logique pour ouvrir l'application de navigation (Google Maps, Waze, etc.)
                  Get.snackbar('Navigation', 'Ouverture de l\'application de navigation...', snackPosition: SnackPosition.BOTTOM);
                },
                icon: const Icon(Icons.navigation),
                label: const Text('Naviguer vers la destination'),
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Logique pour appeler le passager
                  Get.snackbar('Appel', 'Appel du passager...', snackPosition: SnackPosition.BOTTOM);
                },
                icon: const Icon(Icons.phone),
                label: const Text('Contacter le passager'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
              ),
            ],
          ),
        );
      }),
    );
  }
}
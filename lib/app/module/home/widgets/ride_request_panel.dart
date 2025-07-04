import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toleka_driver/app/models/ride_model.dart';
import '../home_controller.dart';

class RideRequestPanel extends StatelessWidget {
  final RideModel ride;
  const RideRequestPanel({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    // TODO: Ajouter un timer de 30 secondes qui refuse automatiquement

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("NOUVELLE COURSE", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
          const SizedBox(height: 16),
          Text(ride.pickupAddress, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text("Gain estimé : ${ride.estimatedPrice.toStringAsFixed(0)} CDF", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Implémenter la logique de refus
                    Get.back(); // Ferme le panneau pour l'instant
                  },
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                  child: const Text("Refuser", style: TextStyle(color: Colors.red)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.acceptRideRequest(ride),
                  child: const Text("Accepter"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
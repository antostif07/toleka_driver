// lib/app/modules/ride_requests/ride_requests_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_pages.dart';
import 'ride_requests_controller.dart';

class RideRequestsView extends GetView<RideRequestsController> {
  const RideRequestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demandes de Course en Attente'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.pendingRequests.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text('Aucune demande de course en attente pour le moment.',
                    textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.pendingRequests.length,
          itemBuilder: (context, index) {
            final request = controller.pendingRequests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('De: ${request.pickupAddress}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('À: ${request.destinationAddress}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Prix Estimé: ${request.estimatedPrice.toStringAsFixed(0)} CFA', style: const TextStyle(color: Colors.green, fontSize: 15)),
                    Text('Demandé à: ${request.createdAt.toLocal().toString().split('.')[0]}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => controller.rejectRequest(request),
                          icon: const Icon(Icons.cancel_outlined),
                          label: const Text('Refuser'),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            controller.acceptRequest(request);
                            Get.offNamed(Routes.activeRide, arguments: request); // Naviguer vers la course active
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Accepter'),
                          style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
// lib/app/modules/earnings_history/earnings_history_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'earnings_history_controller.dart';

class EarningsHistoryView extends GetView<EarningsHistoryController> {
  const EarningsHistoryView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Gains & Historique'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Section Gains Totaux
            Card(
              margin: const EdgeInsets.all(16.0),
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total des Gains:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Obx(() => Text(
                      '${controller.totalEarnings.value.toStringAsFixed(0)} CFA',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                    )),
                  ],
                ),
              ),
            ),
            const Divider(),
            // Liste des Courses Terminées
            Expanded(
              child: controller.completedRides.isEmpty
                  ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 80, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Aucune course terminée pour le moment.',
                        textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ],
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                itemCount: controller.completedRides.length,
                itemBuilder: (context, index) {
                  final ride = controller.completedRides[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12.0),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.green[600]),
                      title: Text('Course de ${ride.pickupAddress} à ${ride.destinationAddress}'),
                      subtitle: Text('Terminée le ${ride.completedAt?.toLocal().toString().split('.')[0] ?? 'N/A'}'),
                      trailing: Text('${ride.estimatedPrice.toStringAsFixed(0)} CFA', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
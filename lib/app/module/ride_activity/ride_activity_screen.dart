import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';

import '../../models/ride_model.dart';
import 'ride_activity_controller.dart';

class RideActivityScreen extends StatelessWidget {
  const RideActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RideActivityController controller = Get.put(RideActivityController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activité des courses', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.0),),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // La vue principale est une Column
        return Column(
          children: [
            _buildWeekSelectorAndSummary(controller),

            // Si la liste est vide, on affiche le message approprié
            if (controller.dailyActivities.isEmpty)
              Expanded(child: _noActivityView())
            else
            // Sinon, on affiche la liste scrollable avec en-têtes
              Expanded(child: _buildGroupedListView(controller)),
          ],
        );
      }),
    );
  }

  /// Construit la carte supérieure avec le sélecteur de semaine et les stats.
  Widget _buildWeekSelectorAndSummary(RideActivityController controller) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.withAlpha((0.1*255).toInt()), spreadRadius: 1, blurRadius: 5)
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_new), onPressed: controller.previousWeek, iconSize: 18),
              Text(controller.selectedWeekRange, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: controller.nextWeek, iconSize: 18),
            ],
          ),
          // Remplacez par votre OnlineStatsWidget stylisé si vous l'avez
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Gains', '\$${controller.weeklyEarnings.toStringAsFixed(2)}'),
                _buildStatColumn('En ligne', '3h 12min'), // Valeur en dur pour l'exemple
                _buildStatColumn('Courses', controller.weeklyRides.toString()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// La liste qui gère les en-têtes "sticky".
  Widget _buildGroupedListView(RideActivityController controller) {
    return CustomScrollView(
      slivers: controller.dailyActivities.map((dayActivity) {
        return SliverStickyHeader(
          // L'en-tête de la journée
          header: _buildDateHeader(dayActivity.date, dayActivity.dailyTotal),
          // Le contenu de la journée (les courses)
          sliver: dayActivity.rides.isEmpty
              ? SliverToBoxAdapter(child: _dailyNoActivityView())
              : SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildRideItem(dayActivity.rides[i]),
              childCount: dayActivity.rides.length,
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Construit un en-tête de date ("sticky header").
  Widget _buildDateHeader(DateTime date, double total) {
    return Container(
      color: Colors.grey[200],
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(DateFormat('EEE, d MMM').format(date), style: const TextStyle(fontWeight: FontWeight.bold)),
          Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  /// Construit une seule ligne pour une course.
  Widget _buildRideItem(Ride ride) {
    return ListTile(
      leading: const Icon(Icons.directions_car_filled),
      title: Text(ride.destination),
      subtitle: Text(DateFormat('hh:mm a').format(ride.timestamp).toLowerCase()),
      trailing: Text('\$${ride.amount.toStringAsFixed(2)}'),
      dense: true,
    );
  }

  // Petits widgets d'aide pour les stats et les états "sans activité"
  Widget _buildStatColumn(String title, String value) => Column(children: [
    Text(title, style: TextStyle(color: Colors.grey.shade600)),
    const SizedBox(height: 4),
    Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
  ]);

  // Vue pour quand il n'y a AUCUNE activité de la semaine
  Widget _noActivityView() => const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text("Vous n'avez fait aucune course cette semaine.", textAlign: TextAlign.center, style: TextStyle(fontSize: 18, color: Colors.grey))));

  // Vue pour une journée sans activité
  Widget _dailyNoActivityView() => const Padding(padding: EdgeInsets.symmetric(vertical: 24.0), child: Center(child: Text("Aucune activité.", style: TextStyle(color: Colors.grey))));
}
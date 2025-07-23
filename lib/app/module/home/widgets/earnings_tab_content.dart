import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toleka_driver/app/module/home/widgets/driver_stats.dart';
import 'package:toleka_driver/app/routes/app_pages.dart';

class EarningsTabContent extends StatelessWidget {
  const EarningsTabContent({super.key});

  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView permet au contenu de défiler si l'écran est trop petit.
    return SingleChildScrollView(
      child: Column(
        children: [
          BalanceSectionWidget(),
          TodaysActivityWidget(),
          WeeklySummaryWidget(),
          // Espace en bas pour un meilleur défilement
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class BalanceSectionWidget extends StatelessWidget {
  const BalanceSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFE8F8F5), // Couleur vert menthe très clair
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solde',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text(
            'CDF 127.32',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class TodaysActivityWidget extends StatelessWidget {
  const TodaysActivityWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Activité du jour',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          // Réutilisation de notre widget de statistiques
          const DriverStats(),
          const Divider(height: 6),
          _buildRideHistoryItem(
            context,
            destination: 'Course vers West Field Cafe',
            time: '01:23pm',
            amount: '\$1.23',
          ),
          _buildRideHistoryItem(
            context,
            destination: 'Course vers WeWork',
            time: '02:00pm',
            amount: '\$3.50',
          ),
          _buildRideHistoryItem(
            context,
            destination: 'Course vers la région du centre-ville',
            time: '02:10pm',
            amount: '\$3.50',
          ),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () {
                Get.toNamed(Routes.rideActivity);
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Voir toute l\'activité', style: TextStyle(color: Colors.black87)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, color: Colors.black87, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Méthode d'aide pour construire un élément de la liste des courses
  Widget _buildRideHistoryItem(BuildContext context, {required String destination, required String time, required String amount}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
      leading: const Icon(Icons.directions_car_filled, color: Colors.black),
      title: Text(destination, style: const TextStyle(fontWeight: FontWeight.w500,fontSize: 14,)),
      subtitle: Text(time, style: TextStyle(color: Colors.grey.shade600, fontSize: 12,)),
      trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      onTap: () {},
    );
  }
}

class WeeklySummaryWidget extends StatefulWidget {
  const WeeklySummaryWidget({super.key});

  @override
  State<WeeklySummaryWidget> createState() => _WeeklySummaryWidgetState();
}

class _WeeklySummaryWidgetState extends State<WeeklySummaryWidget> {
  // Une simple variable d'état pour le sélecteur de semaine
  String _currentWeek = "18 Mars - 25 Mars";

  void _previousWeek() { setState(() { _currentWeek = "11 Mars - 17 Mars"; }); }
  void _nextWeek() { setState(() { _currentWeek = "26 Mars - 1 Avr"; }); }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      color: Colors.blueGrey[50]?.withAlpha((0.5 * 255).toInt()), // Fond gris-bleu très clair
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Résumé hebdomadaire',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // La carte du sélecteur de semaine
          Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200)
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: _previousWeek, iconSize: 18),
                      Text(_currentWeek, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      IconButton(icon: const Icon(Icons.arrow_forward_ios), onPressed: _nextWeek, iconSize: 18),
                    ],
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  const DriverStats(),
                  const SizedBox(height: 8),
                ],
              )
          ),
          // Le bouton vert
          // ElevatedButton(
          //   onPressed: () {},
          //   style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.green,
          //       foregroundColor: Colors.white,
          //       elevation: 0,
          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          //       padding: const EdgeInsets.symmetric(vertical: 12)
          //   ),
          //   child: const Row(
          //     children: [
          //       SizedBox(width: 12),
          //       Icon(Icons.star, size: 20),
          //       SizedBox(width: 8),
          //       Expanded(child: Text('Définir un objectif de gains hebdomadaire', style: TextStyle(fontWeight: FontWeight.bold))),
          //       Icon(Icons.arrow_forward_ios, size: 16),
          //       SizedBox(width: 12),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}
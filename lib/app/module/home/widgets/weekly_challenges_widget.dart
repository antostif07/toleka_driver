import 'package:flutter/material.dart';
import 'dart:math';

// Widget principal que vous ajouterez à votre écran
class WeeklyChallengesWidget extends StatefulWidget {
  const WeeklyChallengesWidget({super.key});

  @override
  State<WeeklyChallengesWidget> createState() => _WeeklyChallengesWidgetState();
}

class _WeeklyChallengesWidgetState extends State<WeeklyChallengesWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Données d'exemple pour les défis
  final List<Map<String, dynamic>> challenges = [
    {
      "title": "Ends on Monday",
      "task": "Complete 20 trips and get \$35 extra",
      "progressText": "2 trips done out of 20",
      "progressValue": 0.20, // 20%
    },
    {
      "title": "Ends on Sunday",
      "task": "Drive 50km and get \$15 extra",
      "progressText": "35km done out of 50",
      "progressValue": 0.70, // 70%
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      if (_pageController.page?.round() != _currentPage) {
        setState(() {
          _currentPage = _pageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Weekly Challenges',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          // Le Carrousel de cartes
          SizedBox(
            height: 120, // Hauteur fixe pour le carrousel
            child: PageView.builder(
              controller: _pageController,
              itemCount: challenges.length,
              itemBuilder: (context, index) {
                return _buildChallengeCard(challenges[index]);
              },
            ),
          ),
          const SizedBox(height: 12),
          // Les indicateurs de page (points)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              challenges.length,
                  (index) => _buildPageIndicator(index == _currentPage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challengeData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          // Partie Texte (à gauche)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challengeData['title'], style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 6),
                Text(challengeData['task'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Spacer(),
                Text(
                  challengeData['progressText'],
                  style: const TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Indicateur de progression circulaire (à droite)
          SizedBox(
            width: 70,
            height: 70,
            child: CustomPaint(
              painter: CircularProgressPainter(progress: challengeData['progressValue']),
              child: Center(
                child: Text(
                  '${(challengeData['progressValue'] * 100).toInt()}%',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 8.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.black87 : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}


// Le CustomPainter pour l'indicateur circulaire
class CircularProgressPainter extends CustomPainter {
  final double progress; // 0.0 to 1.0

  CircularProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 8.0;

    // Peinture pour l'arc de fond (le cercle gris)
    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Peinture pour l'arc de progression (le vert)
    final progressPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Extrémités arrondies

    // Dessiner le cercle complet en arrière-plan
    canvas.drawCircle(center, radius, backgroundPaint);

    // Dessiner l'arc de progression
    const startAngle = -pi / 2; // Partir du haut (position 12h)
    final sweepAngle = 2 * pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
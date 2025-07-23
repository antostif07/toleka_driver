// lib/app/data/models/ride_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class RideModel {
  final String? id; // L'ID du document de la course dans Firestore
  final String riderId; // L'UID du passager qui a demandé la course
  final String pickupAddress; // Adresse de départ
  final GeoPoint pickupLocation; // Coordonnées GPS de départ
  final String destinationAddress; // Adresse d'arrivée
  final GeoPoint destinationLocation; // Coordonnées GPS d'arrivée
  final double estimatedPrice; // Prix estimé de la course
  final String status; // Statut de la course (ex: 'pending', 'accepted', 'started', 'completed', 'cancelled')
  final DateTime createdAt; // Timestamp de la création de la demande

  final String vehicleType;
  final int distance; // en mètres
  final int duration; // en secondes

  // Informations qui peuvent être ajoutées plus tard
  final String? assignedDriverId; // L'UID du conducteur assigné à cette course
  final DateTime? acceptedAt; // Timestamp de l'acceptation par le conducteur
  final DateTime? startedAt; // Timestamp du début de la course
  final DateTime? completedAt; // Timestamp de la fin de la course
  final DateTime? cancelledAt; // Timestamp de l'annulation de la course

  final String encodedPolyline;

  RideModel({
    this.id,
    required this.riderId,
    required this.pickupAddress,
    required this.pickupLocation,
    required this.destinationAddress,
    required this.destinationLocation,
    required this.estimatedPrice,
    required this.status,
    required this.vehicleType,
    required this.distance,
    required this.duration,
    required this.createdAt,
    this.assignedDriverId,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    required this.encodedPolyline,
  });

  Map<String, dynamic> toJsonForCreation() {
    return {
      'riderId': riderId,
      'pickupAddress': pickupAddress,
      'pickupLocation': pickupLocation,
      'destinationAddress': destinationAddress,
      'destinationLocation': destinationLocation,
      'estimatedPrice': estimatedPrice,
      'status': status,
      'vehicleType': vehicleType,
      'distance': distance,
      'duration': duration,
      'createdAt': FieldValue.serverTimestamp(), // Géré par le serveur
      'assignedDriverId': null,
      'encodedPolyline': encodedPolyline,
    };
  }

  /// Convertit un objet RideModel en une Map<String, dynamic> pour Firestore.
  Map<String, dynamic> toJson() {
    return {
      'riderId': riderId,
      'pickupAddress': pickupAddress,
      'pickupLocation': pickupLocation,
      'destinationAddress': destinationAddress,
      'destinationLocation': destinationLocation,
      'estimatedPrice': estimatedPrice,
      'status': status,
      'createdAt': createdAt,
      'assignedDriverId': assignedDriverId,
      'acceptedAt': acceptedAt,
      'startedAt': startedAt,
      'completedAt': completedAt,
      'cancelledAt': cancelledAt,
      'vehiculeType': vehicleType,
      'duration': duration,
      'distance': distance,
    };
  }

  /// Crée un objet RideModel à partir d'un DocumentSnapshot de Firestore.
  factory RideModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw "Le document de la course est vide ou n'existe pas !";
    }

    return RideModel(
      id: doc.id,
      riderId: data['riderId'] ?? '',
      pickupAddress: data['pickupAddress'] ?? '',
      pickupLocation: data['pickupLocation'] as GeoPoint,
      destinationAddress: data['destinationAddress'] ?? '',
      destinationLocation: data['destinationLocation'] as GeoPoint,
      estimatedPrice: (data['estimatedPrice'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      assignedDriverId: data['assignedDriverId'] as String?,
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      startedAt: (data['startedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
      vehicleType: data['vehicleType'] ?? 'standard', // Valeur par défaut
      distance: data['distance'] ?? 0,
      duration: data['duration'] ?? 0,
      encodedPolyline: data['encodedPolyline'] ?? '',
    );
  }

  /// Crée une nouvelle instance de RideModel avec des valeurs potentiellement modifiées.
  RideModel copyWith({
    String? id,
    String? riderId,
    String? pickupAddress,
    GeoPoint? pickupLocation,
    String? destinationAddress,
    GeoPoint? destinationLocation,
    double? estimatedPrice,
    String? status,
    DateTime? createdAt,
    String? assignedDriverId,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? vehicleType,
    int? duration,
    int? distance,
    String? encodedPolyline,
  }) {
    return RideModel(
      id: id ?? this.id,
      riderId: riderId ?? this.riderId,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      assignedDriverId: assignedDriverId ?? this.assignedDriverId,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      vehicleType: vehicleType ?? this.vehicleType,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      encodedPolyline: encodedPolyline ?? this.encodedPolyline,
    );
  }
}

class DailyActivity {
  final DateTime date;
  final List<Ride> rides;

  DailyActivity({required this.date, required this.rides});

  // Calcule le total des gains pour la journée.
  double get dailyTotal => rides.fold(0.0, (sum, ride) => sum + ride.amount);
}

/// Représente une seule course effectuée.
class Ride {
  final String destination;
  final DateTime timestamp;
  final double amount;

  Ride({required this.destination, required this.timestamp, required this.amount});
}
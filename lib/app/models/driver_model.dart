import 'package:cloud_firestore/cloud_firestore.dart';

import '../module/driver_preferences/driver_preferences_model.dart';

class Driver {
  final String id;
  final String driverID;
  final String fullName;
  final String email; // E-mail utilisé pour l'authentification Firebase en coulisses
  final String phoneNumber;
  String? profilePictureUrl; // URL de l'image de profil (optionnel)
  final bool? profileCompleted;
  final bool? isApproved;
  final DriverPreferences preferences;

  // Informations sur le véhicule
  final String vehicleModel;
  final String vehicleMark;
  final String vehicleColor;
  final String licensePlate;

  // Données opérationnelles et statistiques
  bool isOnline; // Le conducteur est-il en ligne et disponible ?
  GeoPoint? currentLocation; // Sa position géographique actuelle (peut être null si hors ligne ou non initié)
  double? currentBearing;
  double rating; // Note moyenne du conducteur
  int totalRides; // Nombre total de courses terminées
  double dailyEarnings; // Gains cumulés pour la journée actuelle

  // Timestamps
  final DateTime createdAt; // Date de création du profil
  DateTime? updatedAt; // Date de la dernière mise à jour du profil

  Driver({
    required this.id,
    required this.driverID,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profilePictureUrl,
    this.profileCompleted,
    this.isApproved,
    required this.preferences,
    required this.vehicleModel,
    required this.vehicleMark,
    required this.vehicleColor,
    required this.licensePlate,
    this.isOnline = false, // Par défaut, hors ligne
    this.currentLocation,
    this.currentBearing,
    this.rating = 5.0, // Par défaut, une note parfaite
    this.totalRides = 0,
    this.dailyEarnings = 0.0, // Par défaut, 0 gains
    required this.createdAt,
    this.updatedAt,
  });

  /// Utile pour les opérations `set` ou `update`.
  Map<String, dynamic> toJson() {
    return {
      'driverID': driverID,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'profilePictureUrl': profilePictureUrl,
      'profileCompleted': profileCompleted ?? false,
      'isApproved': isApproved ?? false,
      'preferences': preferences.toMap(),
      'vehicleModel': vehicleModel,
      'vehicleMark': vehicleMark,
      'vehicleColor': vehicleColor,
      'licensePlate': licensePlate,
      'isOnline': isOnline,
      'currentLocation': currentLocation,
      'currentBearing': currentBearing,
      'rating': rating,
      'totalRides': totalRides,
      'dailyEarnings': dailyEarnings,
      'createdAt': createdAt,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Crée un objet Driver à partir d'un DocumentSnapshot de Firestore.
  /// Utile pour récupérer les données depuis la base de données.
  factory Driver.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw "Le document du conducteur est vide ou n'existe pas !";
    }

    return Driver(
      id: doc.id,
      driverID: data['driverID'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] as String?,
      profileCompleted: data['profileCompleted'] ?? false,
      isApproved: data['isApproved'] ?? false,
      preferences: DriverPreferences.fromMap(data['preferences'] as Map<String, dynamic>?),
      vehicleModel: data['vehicleModel'] ?? '',
      vehicleMark: data['vehicleMark'] ?? '',
      vehicleColor: data['vehicleColor'] ?? '',
      licensePlate: data['licensePlate'] ?? '',
      isOnline: data['isOnline'] ?? false,
      currentLocation: data['currentLocation'] as GeoPoint?,
      currentBearing: (data['currentBearing'] as num?)?.toDouble(),
      rating: (data['rating'] ?? 5.0).toDouble(),
      totalRides: (data['totalRides'] ?? 0).toInt(),
      dailyEarnings: (data['dailyEarnings'] ?? 0.0).toDouble(),
      // Convertit le Timestamp de Firestore en DateTime
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  /// Crée une nouvelle instance de Driver avec des valeurs potentiellement modifiées.
  /// Utile pour mettre à jour des propriétés spécifiques sans modifier l'objet original.
  Driver copyWith({
    String? id,
    String? driverID,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profilePictureUrl,
    bool? profileCompleted,
    bool? isApproved,
    DriverPreferences? preferences,
    String? vehicleModel,
    String? vehicleMark,
    String? vehicleColor,
    String? licensePlate,
    bool? isOnline,
    GeoPoint? currentLocation,
    double? currentBearing,
    double? rating,
    int? totalRides,
    double? dailyEarnings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Driver(
      id: id ?? this.id,
      driverID: driverID ?? this.driverID,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      preferences: preferences ?? this.preferences,
      isApproved: isApproved ?? this.isApproved,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleMark: vehicleMark ?? this.vehicleMark,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      licensePlate: licensePlate ?? this.licensePlate,
      isOnline: isOnline ?? this.isOnline,
      currentLocation: currentLocation ?? this.currentLocation,
      currentBearing: currentBearing ?? this.currentBearing,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      dailyEarnings: dailyEarnings ?? this.dailyEarnings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
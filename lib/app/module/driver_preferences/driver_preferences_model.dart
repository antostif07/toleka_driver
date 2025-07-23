// Mettez ce code dans le fichier `driver_preferences_model.dart`

class DriverPreferences {
  final bool acceptsCash;
  final bool autoAcceptTrips;
  final bool excludeLowRatedRiders;
  final bool allowLongDistanceTrips;

  DriverPreferences({
    this.acceptsCash = true,
    this.autoAcceptTrips = false,
    this.excludeLowRatedRiders = false,
    this.allowLongDistanceTrips = false,
  });

  factory DriverPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return DriverPreferences();
    return DriverPreferences(
      acceptsCash: map['acceptsCash'] ?? true,
      autoAcceptTrips: map['autoAcceptTrips'] ?? false,
      excludeLowRatedRiders: map['excludeLowRatedRiders'] ?? false,
      allowLongDistanceTrips: map['allowLongDistanceTrips'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'acceptsCash': acceptsCash,
      'autoAcceptTrips': autoAcceptTrips,
      'excludeLowRatedRiders': excludeLowRatedRiders,
      'allowLongDistanceTrips': allowLongDistanceTrips,
    };
  }

  DriverPreferences copyWith({
    bool? acceptsCash,
    bool? autoAcceptTrips,
    bool? excludeLowRatedRiders,
    bool? allowLongDistanceTrips,
  }) {
    return DriverPreferences(
      acceptsCash: acceptsCash ?? this.acceptsCash,
      autoAcceptTrips: autoAcceptTrips ?? this.autoAcceptTrips,
      excludeLowRatedRiders: excludeLowRatedRiders ?? this.excludeLowRatedRiders,
      allowLongDistanceTrips: allowLongDistanceTrips ?? this.allowLongDistanceTrips,
    );
  }
}
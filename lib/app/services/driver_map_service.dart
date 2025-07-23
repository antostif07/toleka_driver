import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class DriverMapService extends GetxService {
  MapboxMap? mapboxMap;
  PointAnnotationManager? pointAnnotationManager;
  PointAnnotation? userLocationMarker;
  Uint8List? markerImage;

  Future<void> onMapCreated(MapboxMap controller) async {
    mapboxMap = controller;
    await _loadMarkerImage();
    pointAnnotationManager = await mapboxMap?.annotations.createPointAnnotationManager();
    print("[MapService] Carte et manager initialisés.");
  }

  Future<void> _loadMarkerImage() async {
    try {
      final byteData = await rootBundle.load('assets/images/driver-location.png');
      markerImage = byteData.buffer.asUint8List();
    } catch (e) {
      print("[MapService] Erreur chargement image: $e");
    }
  }

  Future<void> updateMarkerPosition(Point position, {double bearing = 0.0}) async {
    if (pointAnnotationManager == null || markerImage == null) return;
    try {
      if (userLocationMarker == null) {
        userLocationMarker = await pointAnnotationManager?.create(PointAnnotationOptions(
          geometry: position, image: markerImage, iconSize: 0.5, iconRotate: bearing,
        ));
      } else {
        userLocationMarker!.geometry = position;
        userLocationMarker!.iconRotate = bearing;
        await pointAnnotationManager?.update(userLocationMarker!);
      }
    } catch (e) {
      print("[MapService] Erreur mise à jour marqueur: $e");
    }
  }

  /// Supprime le marqueur de l'utilisateur de la carte.
  Future<void> removeUserMarker() async {
    // 1. Vérifier que le manager et le marqueur existent
    if (pointAnnotationManager != null && userLocationMarker != null) {
      try {
        // 2. Demander au manager de supprimer l'annotation
        await pointAnnotationManager?.delete(userLocationMarker!);
        print("[MapService] Marqueur utilisateur supprimé de la carte.");

        // 3. Réinitialiser notre référence locale à null
        // C'est crucial pour que la prochaine appelée à `updateMarkerPosition`
        // sache qu'elle doit en CRÉER un nouveau.
        userLocationMarker = null;
      } catch (e) {
        print("[MapService] Erreur lors de la suppression du marqueur: $e");
      }
    }
  }

  void flyTo(Point point, {double zoom = 16.0}) {
    mapboxMap?.flyTo(
      CameraOptions(center: point, zoom: zoom),
      MapAnimationOptions(duration: 1500),
    );
  }
}
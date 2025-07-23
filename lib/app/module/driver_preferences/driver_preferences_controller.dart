import 'package:get/get.dart';

import '../../services/auth_services.dart';
import 'driver_preferences_model.dart';

class DriverPreferencesController extends GetxController {
  final AuthService _authService = Get.find();

  // Garde en mémoire l'état initial des préférences au chargement de la page
  late DriverPreferences _initialPreferences;

  // --- VARIABLES D'ÉTAT RÉACTIVES ---
  final Rx<DriverPreferences> currentPreferences = Rx<DriverPreferences>(DriverPreferences());
  final RxBool isDirty = false.obs; // Vrai si des changements ont été faits
  final RxBool isSaving = false.obs;  // Pour l'indicateur de chargement sur le bouton 'Enregistrer'

  @override
  void onInit() {
    super.onInit();
    // On charge les préférences actuelles du conducteur au démarrage
    final driver = _authService.currentDriver;
    if (driver != null) {
      _initialPreferences = driver.preferences;
      currentPreferences.value = driver.preferences;
    }
  }

  /// Met à jour une préférence et vérifie si des changements ont été faits
  void updatePreference(DriverPreferences newPrefs) {
    currentPreferences.value = newPrefs;
    _checkIfDirty();
  }

  /// Compare les préférences actuelles aux préférences initiales
  void _checkIfDirty() {
    isDirty.value = currentPreferences.value.toMap().toString() != _initialPreferences.toMap().toString();
  }

  /// Annule tous les changements et revient à l'état initial
  void resetPreferences() {
    currentPreferences.value = _initialPreferences;
    _checkIfDirty();
  }

  /// Enregistre les modifications dans la base de données
  Future<void> savePreferences() async {
    if (!isDirty.value) return; // Ne rien faire s'il n'y a pas de changement
    isSaving.value = true;

    try {
      // Logique pour mettre à jour le document Firestore (à implémenter dans AuthService)
      await _authService.updateDriverPreferences(currentPreferences.value);

      // Mettre à jour l'état initial pour refléter les nouvelles préférences sauvegardées
      _initialPreferences = currentPreferences.value;
      isDirty.value = false;

      Get.back(); // Retourner à l'écran précédent
      Get.snackbar('Succès', 'Vos préférences ont été enregistrées.');

    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'enregistrer les préférences.');
    } finally {
      isSaving.value = false;
    }
  }
}

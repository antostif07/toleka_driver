import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'profile_completion_controller.dart';

class Step2VehicleInfo extends StatelessWidget {
  const Step2VehicleInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileCompletionController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Form(
        key: controller.formKeyStep2, // La clé pour cette étape
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Titres ---
            const Text(
              "Étape 3 sur 4", // Mis à jour
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              "Ajoutez votre véhicule",
              style: GoogleFonts.plusJakartaSans(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Votre véhicule doit être de 2005 ou plus récent, avoir au moins 4 portes et ne pas être accidenté.",
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),

            // --- Formulaire ---
            _buildDropdown(
              label: "Marque",
              hint: "ex. Toyota",
              value: controller.make.value,
              items: controller.carMakes,
              onChanged: (value) => controller.make.value = value,
            ),
            const SizedBox(height: 24),
            // Pour le modèle, on va utiliser un champ de texte simple pour l'instant
            _buildTextField(
              controller: controller.modelController,
              label: "Modèle",
              hint: "ex. S4 Avant",
              validator: (val) => val!.isEmpty ? "Champ requis" : null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: controller.yearController,
                    label: "Année",
                    hint: "ex. 2014",
                    keyboardType: TextInputType.number,
                    validator: (val) => val!.isEmpty ? "Requis" : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDropdown(
                    label: "Couleur",
                    hint: "ex. Noir",
                    value: controller.color.value,
                    items: controller.carColors,
                    onChanged: (value) => controller.color.value = value,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: controller.licensePlateController,
              label: "Numéro de plaque d'immatriculation",
              hint: "ex. 6WED298",
              validator: (val) => val!.isEmpty ? "Champ requis" : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  // Helper pour les dropdowns
  Widget _buildDropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column( // Obx pour reconstruire si la valeur change
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey[400])),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (val) => val == null ? "Champ requis" : null,
        ),
      ],
    );
  }
}
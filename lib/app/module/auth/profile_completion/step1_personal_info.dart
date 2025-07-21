import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'profile_completion_controller.dart';

class Step1PersonalInfo extends StatelessWidget {
  const Step1PersonalInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileCompletionController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: controller.formKeyStep1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Étape 1 sur 5", style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Text(
                    "Indiquez vos informations personnelles",
                    style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                ],
              ),
            ),

            _buildTextField(
              controller: controller.fullNameController,
              label: "Nom",
              hint: "ex. John Doe",
              validator: (value) => (value?.isEmpty ?? true) ? "Veuillez entrer votre nom complet" : null,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: controller.emailController,
              label: "Adresse e-mail",
              hint: "ex. abc@email.com",
              keyboardType: TextInputType.emailAddress,
              validator: (value) => (GetUtils.isEmail(value!)) ? null : "Veuillez entrer un e-mail valide",
            ),
            const SizedBox(height: 24),

            // Champ du numéro de téléphone (non modifiable)
            Text("Numéro de téléphone", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Text(
                controller.phoneNumber,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),

            // Termes et Conditions
            _buildTermsAndConditions(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Helper pour créer les champs de texte
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

  // Helper pour les termes et conditions
  Widget _buildTermsAndConditions() {
    final controller = Get.find<ProfileCompletionController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: controller.termsAccepted.value,
            onChanged: (value) => controller.termsAccepted.value = value!,
          ),
        )),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
              children: [
                const TextSpan(text: "En continuant, j'accepte les "),
                TextSpan(
                  text: "termes d'utilisation",
                  style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()..onTap = () { /* Ouvrir le lien des termes */ },
                ),
                const TextSpan(text: " & "),
                TextSpan(
                  text: "politique de confidentialité.",
                  style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                  recognizer: TapGestureRecognizer()..onTap = () { /* Ouvrir le lien de la politique */ },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
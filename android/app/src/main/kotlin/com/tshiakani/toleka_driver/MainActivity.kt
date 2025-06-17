package com.tshiakani.toleka_driver

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        // Appeler installSplashScreen() avant super.onCreate()
        // Ceci gère la logique de l'API Splash Screen pour Android 12+
        // et applique le postSplashScreenTheme une fois le splash terminé.
        val splashScreen = installSplashScreen()
        super.onCreate(savedInstanceState)

        // Optionnel : Garder le splash screen à l'écran un peu plus longtemps
        // Vous pouvez le combiner avec le chargement de vos données initiales Flutter.
        // splashScreen.setKeepOnScreenCondition { true } // Garde le splash screen indéfiniment
        // Ou
        // splashScreen.setKeepOnScreenCondition { yourViewModel.isLoading.value } // Exemple avec un ViewModel
    }
}

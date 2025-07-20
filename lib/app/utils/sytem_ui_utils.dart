import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SystemUiUtils {
  static void setTransparentStatusBar({
    Brightness iconBrightness = Brightness.light,
    Brightness statusBarBrightness = Brightness.dark,
  }) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: iconBrightness, // Pour Android
      statusBarBrightness: statusBarBrightness, // Pour iOS
    ));
  }
}
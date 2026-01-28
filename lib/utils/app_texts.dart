import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  /// Default Text Style with Plus Jakarta Sans font family
  static TextStyle get defaultTextStyle => const TextStyle(
    fontFamily: 'Plus Jakarta Sans',  // Set the font family to 'Plus Jakarta Sans'
    fontSize: 16,           // Default font size
    fontWeight: FontWeight.normal,  // Default font weight
    color: Colors.black,    // Default text color
  );

  /// Large Heading
  static TextStyle get largeHeading => const TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  /// Small Text
  static TextStyle get smallText => const TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
  );
}

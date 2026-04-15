/**
import 'package:flutter/material.dart';

/// 1️⃣ Alert Types (call alerts by name/type)
enum SupportAlertType {
  clam,
  encouraging,
  logical,
}

/// 2️⃣ Main Alert Class (PUBLIC API)
class SupportAlertCards {
  static void show(
      BuildContext context, {
        required SupportAlertType type,
        VoidCallback? onButtonTap,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SupportAlertDialog(
        type: type,
        onButtonTap: onButtonTap,
      ),
    );
  }
}

/// 3️⃣ Internal Dialog UI
class _SupportAlertDialog extends StatelessWidget {
  final SupportAlertType type;
  final VoidCallback? onButtonTap;

  const _SupportAlertDialog({
    required this.type,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _alertConfig(type);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F8FF),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator
            Container(
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 20),

            ///  ==========
            /// --- gif ---
            /// ===========
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: config.backgroundColor,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  config.imagePath,
                  fit: BoxFit.contain,
                  gaplessPlayback: true, // 🔥 important for GIF
                ),
              ),
            ),


            const SizedBox(height: 24),

            // Message
            Text(
              config.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 28),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.thumb_up),
                label: Text(config.buttonText),
                onPressed: () {
                  Navigator.pop(context);
                  onButtonTap?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6AA8FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4️⃣ Alert Configuration (EDIT ONLY HERE)
class _AlertConfig {
  final String message;
  final String buttonText;
  final String imagePath;
  final Color backgroundColor;

  _AlertConfig({
    required this.message,
    required this.buttonText,
    required this.imagePath,
    required this.backgroundColor,
  });
}

/// 5️⃣ Alert Content by Type
_AlertConfig _alertConfig(SupportAlertType type) {
  switch (type) {
    case SupportAlertType.clam:
      return _AlertConfig(
        message:
        "You’ve completed all your tasks for today.\nTake a moment to breathe — you did well.",
        buttonText: "Well done",
        imagePath: "assets/images/task_completed_popup.gif",
        backgroundColor: const Color(0xFF8FB6FF),
      );

    case SupportAlertType.encouraging:
      return _AlertConfig(
        message: "Please check the details and try again.",
        buttonText: "Okay",
        imagePath: "assets/images/task_completed_popup.gif",
        backgroundColor: Colors.orange.shade200,
      );

    case SupportAlertType.logical:
      return _AlertConfig(
        message: "Here is something useful for you.",
        buttonText: "Got it",
        imagePath: "assets/images/task_completed_popup.gif",
        backgroundColor: Colors.green.shade200,
      );
  }
}
*/








///
///
///
///
/// todo::updating with full design
///
///
///
///





// import 'package:flutter/material.dart';
//
// /// ============================================================================
// /// 🎯 SUPPORT ALERT CARDS - SINGLE FILE IMPLEMENTATION
// /// ============================================================================
// /// Usage:
// ///   SupportAlertCards.show(context, type: SupportAlertType.calm50);
// ///   SupportAlertCards.show(context, type: SupportAlertType.calm100);
// /// ============================================================================
//
// /// 1️⃣ Unified Alert Types (50% and 100% variants)
// enum SupportAlertType {
//   // 50% Halfway Alerts
//   calm50,
//   encouraging50,
//   logical50,
//
//   // 100% Completed Alerts
//   calm100,
//   encouraging100,
//   logical100,
// }
//
// /// 2️⃣ Main Alert Class (PUBLIC API - Static)
// class SupportAlertCards {
//   static void show(
//       BuildContext context, {
//         required SupportAlertType type,
//         VoidCallback? onButtonTap,
//       }) {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => _SupportAlertDialog(
//         type: type,
//         onButtonTap: onButtonTap,
//       ),
//     );
//   }
// }
//
// /// 3️⃣ Internal Dialog UI (Handles all types)
// class _SupportAlertDialog extends StatelessWidget {
//   final SupportAlertType type;
//   final VoidCallback? onButtonTap;
//
//   const _SupportAlertDialog({
//     required this.type,
//     this.onButtonTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final config = _alertConfig(type);
//     final isCompleted = type.name.endsWith('100');
//
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: const EdgeInsets.all(20),
//       child: Container(
//         padding: const EdgeInsets.all(24),
//         decoration: BoxDecoration(
//           color: config.cardColor,
//           borderRadius: BorderRadius.circular(28),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Close button (X)
//             Align(
//               alignment: Alignment.topRight,
//               child: GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     color: Colors.red.shade400,
//                     shape: BoxShape.circle,
//                   ),
//                   child: const Icon(
//                     Icons.close,
//                     color: Colors.white,
//                     size: 16,
//                   ),
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             /// ==========
//             /// GIF Image (Circle) - Same for all types
//             /// ==========
//             Container(
//               height: 160,
//               width: 160,
//               decoration: BoxDecoration(
//                 color: config.imageBackgroundColor,
//                 shape: BoxShape.circle,
//               ),
//               child: ClipOval(
//                 child: Image.asset(
//                   config.imagePath,
//                   fit: BoxFit.contain,
//                   gaplessPlayback: true, // 🔥 Important for smooth GIF
//                 ),
//               ),
//             ),
//
//             const SizedBox(height: 28),
//
//             // Main Title (Good job! 🎉 / All Done! 🎊)
//             Text(
//               config.title,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             // Subtitle (You're halfway there / 100% Complete)
//             Text(
//               config.subtitle,
//               textAlign: TextAlign.center,
//               style: const TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.black87,
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             // Description text
//             Text(
//               config.description,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w400,
//                 color: Colors.grey.shade700,
//                 height: 1.4,
//               ),
//             ),
//
//             const SizedBox(height: 32),
//
//             // Action Button (Same style, different text/icon)
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: ElevatedButton.icon(
//                 icon: Icon(
//                   isCompleted ? Icons.celebration : Icons.thumb_up,
//                   size: 20,
//                 ),
//                 label: Text(
//                   config.buttonText,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 onPressed: () {
//                   Navigator.pop(context);
//                   onButtonTap?.call();
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF6AA8FF),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   elevation: 0,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /// 4️⃣ Alert Configuration Model (Static Data)
// class _AlertConfig {
//   final String title;
//   final String subtitle;
//   final String description;
//   final String buttonText;
//   final String imagePath;
//   final Color cardColor;
//   final Color imageBackgroundColor;
//
//   const _AlertConfig({
//     required this.title,
//     required this.subtitle,
//     required this.description,
//     required this.buttonText,
//     required this.imagePath,
//     required this.cardColor,
//     required this.imageBackgroundColor,
//   });
// }
//
// /// 5️⃣ Alert Content by Type (EDIT ONLY HERE - Static Data)
// _AlertConfig _alertConfig(SupportAlertType type) {
//   switch (type) {
//   // ==================== 50% HALFWAY ALERTS ====================
//     case SupportAlertType.calm50:
//       return const _AlertConfig(
//         title: "Good job! 🎉",
//         subtitle: "You're halfway there.",
//         description: "Take it step by step — you're doing just fine.",
//         buttonText: "Continue",
//         imagePath: "assets/images/halfway_calm.gif",
//         cardColor: Color(0xFFE8F4FF), // Light blue
//         imageBackgroundColor: Colors.white,
//       );
//
//     case SupportAlertType.encouraging50:
//       return const _AlertConfig(
//         title: "Awesome! 🌟",
//         subtitle: "Halfway to success!",
//         description: "Keep going! You're making great progress.",
//         buttonText: "Keep Going",
//         imagePath: "assets/images/halfway_encouraging.gif",
//         cardColor: Color(0xFFFFF3E0), // Light orange/peach
//         imageBackgroundColor: Colors.white,
//       );
//
//     case SupportAlertType.logical50:
//       return const _AlertConfig(
//         title: "Progress Update 📊",
//         subtitle: "50% Complete",
//         description: "You've completed half of your tasks. Stay focused!",
//         buttonText: "Got it",
//         imagePath: "assets/images/halfway_logical.gif",
//         cardColor: Color(0xFFE8F5E9), // Light green
//         imageBackgroundColor: Colors.white,
//       );
//
//   // ==================== 100% COMPLETED ALERTS ====================
//     case SupportAlertType.calm100:
//       return const _AlertConfig(
//         title: "All Done! 🎊",
//         subtitle: "You've completed all tasks!",
//         description: "Great work! Take a moment to celebrate your achievement.",
//         buttonText: "Awesome!",
//         imagePath: "assets/images/completed_calm.gif",
//         cardColor: Color(0xFFE8F4FF), // Light blue
//         imageBackgroundColor: Colors.white,
//       );
//
//     case SupportAlertType.encouraging100:
//       return const _AlertConfig(
//         title: "Congratulations! 🏆",
//         subtitle: "100% Complete!",
//         description: "Amazing job! You crushed all your goals today!",
//         buttonText: "Celebrate!",
//         imagePath: "assets/images/completed_encouraging.gif",
//         cardColor: Color(0xFFFFF3E0), // Light orange
//         imageBackgroundColor: Colors.white,
//       );
//
//     case SupportAlertType.logical100:
//       return const _AlertConfig(
//         title: "Task Complete ✓",
//         subtitle: "All items finished",
//         description: "You've successfully completed 100% of your tasks.",
//         buttonText: "Well Done",
//         imagePath: "assets/images/completed_logical.gif",
//         cardColor: Color(0xFFE8F5E9), // Light green
//         imageBackgroundColor: Colors.white,
//       );
//   }
// }








import 'package:flutter/material.dart';

/// ============================================================================
/// 🎯 SUPPORT ALERT CARDS - 50% & 100% VARIANTS
/// ============================================================================
/// Usage:
///   SupportAlertCards.show(context, type: SupportAlertType.calm50);
///   SupportAlertCards.show(context, type: SupportAlertType.calm100);
/// ============================================================================

/// 1️⃣ Alert Types (50% and 100% variants)
enum SupportAlertType {
  // 50% Halfway Alerts
  calm50,
  encouraging50,
  logical50,

  // 100% Completed Alerts
  calm100,
  encouraging100,
  logical100,
}

/// 2️⃣ Main Alert Class (PUBLIC API)
class SupportAlertCards {
  static void show(
      BuildContext context, {
        required SupportAlertType type,
        VoidCallback? onButtonTap,
      }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SupportAlertDialog(
        type: type,
        onButtonTap: onButtonTap,
      ),
    );
  }
}

/// 3️⃣ Internal Dialog UI (ORIGINAL DESIGN PRESERVED)
class _SupportAlertDialog extends StatelessWidget {
  final SupportAlertType type;
  final VoidCallback? onButtonTap;

  const _SupportAlertDialog({
    required this.type,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = _alertConfig(type);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F8FF), // ✅ Fixed card color
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag indicator
            Container(
              height: 5,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 20),

            ///  ==========
            /// --- gif ---
            /// ===========
            Container(
              height: 150,
              width: 150,
              decoration: BoxDecoration(
                color: config.backgroundColor, // ✅ Changes per mode
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  config.imagePath, // ✅ Changes per mode
                  fit: BoxFit.contain,
                  gaplessPlayback: true, // 🔥 important for GIF
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Message ✅ Changes per mode
            Text(
              config.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 28),

            // Action Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.thumb_up),
                label: Text(config.buttonText), // ✅ Changes per mode
                onPressed: () {
                  Navigator.pop(context);
                  onButtonTap?.call();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6AA8FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 4️⃣ Alert Configuration (EDIT ONLY HERE)
class _AlertConfig {
  final String message;
  final String buttonText;
  final String imagePath;
  final Color backgroundColor;

  _AlertConfig({
    required this.message,
    required this.buttonText,
    required this.imagePath,
    required this.backgroundColor,
  });
}

/// 5️⃣ Alert Content by Type (STATIC DATA - EDIT ONLY HERE)
_AlertConfig _alertConfig(SupportAlertType type) {
  switch (type) {
  // ==================== 50% HALFWAY ALERTS ====================
    case SupportAlertType.calm50:
      return _AlertConfig(
        message: "Good job! 🎉\nYou're halfway there.",
        buttonText: "Continue",
        imagePath: "assets/icons/calm50.gif",
        backgroundColor: const Color(0xFF8FB6FF), // Blue
      );

    case SupportAlertType.encouraging50:
      return _AlertConfig(
        message: "Awesome! 🌟\nHalfway to success!",
        buttonText: "Keep Going",
        imagePath: "assets/icons/encouraging50.gif",
        backgroundColor: Colors.orange.shade200, // Orange
      );

    case SupportAlertType.logical50:
      return _AlertConfig(
        message: "Progress Update 📊\n50% Complete",
        buttonText: "Got it",
        imagePath: "assets/icons/logical50.gif",
        backgroundColor: Colors.green.shade200, // Green
      );

  // ==================== 100% COMPLETED ALERTS ====================
    case SupportAlertType.calm100:
      return _AlertConfig(
        message:
        "You've completed all your tasks for today.\nTake a moment to breathe — you did well.",
        buttonText: "Well done",
        imagePath: "assets/icons/task_completed_popup.gif",
        backgroundColor: const Color(0xFF8FB6FF), // Blue
      );

    case SupportAlertType.encouraging100:
      return _AlertConfig(
        message: "Congratulations! 🏆\n100% Complete!",
        buttonText: "Celebrate!",
        imagePath: "assets/icons/task_completed_popup.gif",
        backgroundColor: Colors.orange.shade200, // Orange
      );

    case SupportAlertType.logical100:
      return _AlertConfig(
        message: "Task Complete ✓\nAll items finished",
        buttonText: "Well Done",
        imagePath: "assets/icons/task_completed_popup.gif",
        backgroundColor: Colors.green.shade200, // Green
      );
  }
}


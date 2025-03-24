import 'package:flutter/material.dart';
import '../services/emergency_service.dart';

class EmergencyGestureDetector extends StatelessWidget {
  final Widget child;
  final EmergencyService _emergencyService = EmergencyService();

  EmergencyGestureDetector({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        // Check if it's a downward swipe
        if (details.primaryVelocity! > 0) {
          _emergencyService.handleSwipeDown();
        }
      },
      // Enable multi-touch gestures
      behavior: HitTestBehavior.translucent,
      child: child,
    );
  }
}

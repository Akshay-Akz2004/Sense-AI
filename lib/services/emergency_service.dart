import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vibration/vibration.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class EmergencyService {
  static final EmergencyService _instance = EmergencyService._internal();
  factory EmergencyService() => _instance;
  EmergencyService._internal();

  bool _isProcessingEmergency = false;
  Position? _lastKnownPosition;
  DateTime? _lastSwipeTime;
  bool _firstSwipeDetected = false;

  String _generateGoogleMapsUrl(Position position) {
    return 'https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}';
  }

  Future<void> handleSwipeDown() async {
    final now = DateTime.now();

    // If this is the first swipe
    if (!_firstSwipeDetected) {
      _firstSwipeDetected = true;
      _lastSwipeTime = now;

      // Vibrate to confirm first swipe
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 500);
      }

      // Start a timer to reset if second swipe doesn't happen within 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        if (_firstSwipeDetected) {
          _firstSwipeDetected = false;
          _lastSwipeTime = null;
        }
      });
    }
    // If this is the second swipe within 3 seconds
    else if (_lastSwipeTime != null &&
        now.difference(_lastSwipeTime!) <= Duration(seconds: 3)) {
      _firstSwipeDetected = false;
      _lastSwipeTime = null;
      await triggerEmergency();
    }
  }

  Future<void> triggerEmergency() async {
    if (_isProcessingEmergency) {
      print('Already processing emergency, skipping');
      return;
    }

    print('Triggering emergency...');
    _isProcessingEmergency = true;

    try {
      // Vibrate to confirm emergency trigger
      if (await Vibration.hasVibrator() ?? false) {
        await Vibration.vibrate(duration: 1000);
        print('Emergency confirmation vibration triggered');
      }

      // Get current location
      print('Getting current location...');
      _lastKnownPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print(
          'Location obtained: ${_lastKnownPosition!.latitude}, ${_lastKnownPosition!.longitude}');

      // Get user ID from Supabase
      final userId = Supabase.instance.client.auth.currentUser?.id;
      print('User ID: $userId');

      if (userId != null && _lastKnownPosition != null) {
        // Get guardian email from profiles table
        print('Fetching guardian email...');
        final profileRes = await Supabase.instance.client
            .from('profiles')
            .select('email')
            .eq('user_id', userId)
            .single();

        if (profileRes != null && profileRes['email'] != null) {
          print('Guardian email found: ${profileRes['email']}');
          // Send email to guardian
          await _sendEmergencyEmail(profileRes['email']);
        } else {
          print('No guardian email found in profile');
        }
      }
    } catch (e) {
      print('Error triggering emergency: $e');
    } finally {
      // Add a delay before allowing new emergency triggers
      await Future.delayed(Duration(seconds: 2));
      _isProcessingEmergency = false;
    }
  }

  Future<void> _sendEmergencyEmail(String recipientEmail) async {
    try {
      final smtpServer = gmail('seeing37ai@gmail.com', 'bwxb xzhq vrgu yabq');

      final mapsUrl = _generateGoogleMapsUrl(_lastKnownPosition!);
      final formattedTime = DateTime.now().toString().split('.')[0];

      final message = Message()
        ..from = Address('seeing37ai@gmail.com', 'Sense AI Emergency System')
        ..recipients.add(recipientEmail)
        ..subject = 'URGENT: Emergency Alert from Sense AI'
        ..text = '''
Dear Guardian,

This is an automated emergency alert from the Sense AI system.

Your ward has triggered an emergency alert at ${formattedTime}.

Location Details:
- Latitude: ${_lastKnownPosition?.latitude}
- Longitude: ${_lastKnownPosition?.longitude}
- Google Maps Link: $mapsUrl

Please take immediate action to check on their well-being.

Best regards,
Sense AI Emergency System
''';

      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString());
    } catch (e) {
      print('Error sending email: $e');
    }
  }
}

// services/phone_service.dart
import 'package:url_launcher/url_launcher.dart';

class PhoneService {
  // Function to launch a phone call
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
      return true;
    }
    return false;
  }

  // Function to send an SMS
  static Future<bool> sendSms(String phoneNumber) async {
    final Uri smsUri = Uri(scheme: 'sms', path: phoneNumber);
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
      return true;
    }
    return false;
  }
}
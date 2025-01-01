import 'package:flutter/cupertino.dart';

class LoginPageViewModel with ChangeNotifier {
  bool _isOtpScreen = false;
  String _verificationId = '';
  String _phoneNumber = '';

  bool get isOtpScreen => _isOtpScreen;
  String get verificationId => _verificationId;
  String get phoneNumber => _phoneNumber;

  setOptScreen(bool value) {
    _isOtpScreen = value;
    notifyListeners();
  }

  setVerificationId(String value) {
    _verificationId = value;
    notifyListeners();
  }

  setPhoneNumber(String value) {
    _phoneNumber = value;
    notifyListeners();
  }

  setBoth(bool value, String value1) {
    _isOtpScreen = value;
    _verificationId = value1;
    notifyListeners();
  }
}

import 'package:flutter/foundation.dart';

class DeepLink with ChangeNotifier, DiagnosticableTreeMixin {
  String _deepLinkUrl = '';
  String _inAppUrl = '';

  String get deepLinkUrl => _deepLinkUrl;
  String get inAppUrl => _inAppUrl;

  void setDeepLinkUrl(value) {
    _deepLinkUrl = value;
    notifyListeners();
  }

  void setInAppUrl(value) {
    _inAppUrl = value;
    notifyListeners();
  }

  /// Makes `Counter` readable inside the devtools by listing all of its properties
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('deepLinkUrl', _deepLinkUrl));
    properties.add(StringProperty('inAppUrl', _inAppUrl));
  }
}

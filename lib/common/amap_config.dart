import 'package:amap_flutter_base/amap_flutter_base.dart';

class AmapConfig {
  static const AMapApiKey amapApiKeys = AMapApiKey(
    androidKey: '9eb2423fb48ec22702d79b1b450443e5',
    iosKey: '申请的iOS平台的key',
  );

  static const AMapPrivacyStatement amapPrivacyStatement =
      AMapPrivacyStatement(hasContains: true, hasShow: true, hasAgree: true);
}

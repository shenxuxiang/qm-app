import 'package:x_amap_base/x_amap_base.dart';

class AmapConfig {
  static const AMapApiKey amapApiKeys = AMapApiKey(
    androidKey: '9eb2423fb48ec22702d79b1b450443e5',
    iosKey: '4dfdec97b7bf0b8c13e94777103015a9',
  );

  /// 构造 AMapPrivacyStatement
  ///
  /// [hasContains] 隐私权政策是否包含高德开平隐私权政策
  ///
  /// [hasShow] 隐私权政策是否弹窗展示告知用户
  ///
  /// [hasAgree] 隐私权政策是否已经取得用户同意
  static const AMapPrivacyStatement amapPrivacyStatement = AMapPrivacyStatement(
    hasShow: true,
    hasAgree: true,
    hasContains: true,
  );
}

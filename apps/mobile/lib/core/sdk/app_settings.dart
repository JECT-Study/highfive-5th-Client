import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// 이 앱의 설정 화면(iOS 설정 > highfive)을 연다. 거부한 권한은 여기서만 다시 켤 수 있다.
/// Android는 카메라·사진에 권한을 쓰지 않아 부를 일이 없다. 열지 못하면 false.
Future<bool> openAppSettings() {
  if (defaultTargetPlatform != TargetPlatform.iOS) return Future.value(false);
  return launchUrl(Uri.parse('app-settings:'));
}

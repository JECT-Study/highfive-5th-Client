import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'app/app.dart';
import 'app/di.dart';
import 'app/env.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final env = AppEnv.fromEnvironment();
  await KakaoSdk.init(nativeAppKey: env.kakaoNativeAppKey);
  setupDi(env);
  runApp(const ProviderScope(child: HighfiveApp()));
}

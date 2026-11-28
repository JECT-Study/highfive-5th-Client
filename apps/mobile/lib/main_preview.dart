import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'app/env.dart';
import 'app/offline_preview_app.dart';

/// 명시적으로 -t lib/main_preview.dart를 선택한 dev/debug 실행에만 사용한다.
/// 실제 main.dart의 SDK·DI·저장소·세션 bootstrap은 호출하지 않는다.
void main() {
  requireOfflinePreview(
    flavor: AppEnv.fromEnvironment().flavor,
    debug: kDebugMode,
  );
  WidgetsFlutterBinding.ensureInitialized();
  // OfflinePreviewApp이 격리된 단일 ProviderScope와 주입을 함께 소유한다.
  runApp(const OfflinePreviewApp());
}

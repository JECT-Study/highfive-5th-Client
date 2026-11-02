import 'package:get_it/get_it.dart';

/// 앱 공통 객체 컨테이너.
///
/// 등록은 `app/di.dart`에서만, 조회는 연결 Provider(`app/providers.dart`,
/// `features/<feature>/presentation/providers/`)에서만 한다.
/// core에 두는 이유: features가 app을 import하지 않고도 연결 Provider를 만들 수 있게 하려는 것.
final getIt = GetIt.instance;

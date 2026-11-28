import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/lineup/presentation/providers/lineup_providers.dart';

/// 곡 시트와 슬롯 설정은 이 페이지·세션에서만 살아 있는 Navigator에 쌓는다.
/// GoRouter는 같은 경로의 인증 갱신 때 Page를 재생성하지 않을 수 있으므로,
/// 세션 저장소 교체도 구독하여 Navigator 전체를 폐기한다.
class LineupRouteScope extends ConsumerStatefulWidget {
  const LineupRouteScope({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<LineupRouteScope> createState() => _LineupRouteScopeState();
}

class _LineupRouteScopeState extends ConsumerState<LineupRouteScope> {
  GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    ref.listen(lineupRepositoryProvider, (previous, next) {
      if (previous != next) {
        setState(() => _navigatorKey = GlobalKey<NavigatorState>());
      }
    });
    ref.watch(lineupRepositoryProvider);
    return NavigatorPopHandler<void>(
      onPopWithResult: (_) => _navigatorKey.currentState!.maybePop(),
      child: Navigator(
        key: _navigatorKey,
        pages: [MaterialPage<void>(child: widget.child)],
        onDidRemovePage: (_) {},
      ),
    );
  }
}

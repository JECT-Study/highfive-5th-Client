import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/performances/presentation/providers/concert_detail_providers.dart';
import '../features/performances/presentation/providers/concert_management_providers.dart';
import '../features/performances/presentation/providers/concert_participants_providers.dart';
import 'providers.dart';
import '../features/auth/presentation/view_models/session_view_model.dart';

/// fake 삭제 기록을 현재 로그인 세션에 한정한다.
/// 세션이 바뀌면 기존 요청·Provider 트리도 함께 버린다.
class ConcertSessionScope extends ConsumerWidget {
  const ConcertSessionScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    if (session.isLoading && !session.hasValue && !session.hasError) {
      return const SizedBox.shrink();
    }
    if (session.value == null) return child;
    final repository = ref.watch(sessionConcertRepositoryProvider);
    return ProviderScope(
      key: ObjectKey(repository),
      overrides: [
        concertRepositoryProvider.overrideWithValue(repository),
        concertParticipantsRepositoryProvider.overrideWithValue(repository),
        concertManagementRepositoryProvider.overrideWithValue(repository),
      ],
      child: child,
    );
  }
}

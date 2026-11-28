import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/ticket_settings_repository.dart';
import '../../models/ticket_role.dart';
import '../../models/ticket_settings.dart';
import '../view_models/ticket_settings_view_model.dart';

// 명세 없음: 합성 dev 세션의 메모리만 사용한다. 경로 재진입 시 저장 일정을 복원한다.
// 실제 로그인 세션·기기 저장소와 연결하지 않으며 role/actor/concert별로 분리한다.
final ticketSettingsStoreProvider =
    Provider.family<TicketSettingsStore, TicketPageScope>(
      (ref, scope) => TicketSettingsStore(scope),
    );

typedef TicketSettingsLeaseKey = ({
  TicketPageScope scope,
  ValueListenable<TicketPageScope>? actorScope,
  Object route,
});

final ticketSettingsClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// 저장값은 dev 메모리에, 명령/읽기 권한은 경로별 lease에 둔다.
final ticketSettingsLeaseProvider = Provider.autoDispose
    .family<TicketSettingsViewModel, TicketSettingsLeaseKey>((ref, key) {
      final model = TicketSettingsViewModel(
        TicketSettingsRepository(
          role: key.scope.role,
          concert: TicketSettingsConcert.demo,
          concertId: key.scope.concertId,
          actorId: key.scope.actorId,
          now: ref.watch(ticketSettingsClockProvider),
          store: ref.watch(ticketSettingsStoreProvider(key.scope)),
          currentScope: () => key.actorScope?.value ?? key.scope,
        ),
      );
      // 한 프레임 사이에 같은 actor로 복귀해도 이전 핸들은 다시 살아나지 않는다.
      void revoke() => model.revoke();
      key.actorScope?.addListener(revoke);
      ref.onDispose(() {
        key.actorScope?.removeListener(revoke);
        model.dispose();
      });
      return model;
    });

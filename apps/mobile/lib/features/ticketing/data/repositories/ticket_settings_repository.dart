import '../../models/ticket_role.dart';
import '../../models/ticket_schedule.dart';
import '../../models/ticket_settings.dart';

/// 합성 dev 세션 메모리. 읽기/쓰기는 권한을 검증하는 경로별 저장소만 수행한다.
class TicketSettingsStore {
  TicketSettingsStore(this.scope);

  final TicketPageScope scope;
  TicketSettings? _saved;
}

/// 명세 없음: 네트워크·영속 저장 없이 한 행위자/공연 범위에서만 유지하는 미리보기 저장소.
class TicketSettingsRepository implements TicketScheduleSource {
  TicketSettingsRepository({
    required this.role,
    required this.concert,
    required this.actorId,
    required this.now,
    this.concertId = ticketPreviewConcertId,
    TicketSettingsStore? store,
    this.currentScope,
  }) : _store =
           store ??
           TicketSettingsStore((
             concertId: concertId,
             actorId: actorId,
             role: role,
           ));

  final TicketRole role;
  final TicketSettingsConcert concert;
  final String actorId;
  final String concertId;
  final DateTime Function() now;
  final TicketPageScope Function()? currentScope;
  final TicketSettingsStore _store;
  bool _active = true;

  bool get canEdit =>
      _active &&
      role == TicketRole.organizer &&
      actorId == ticketPreviewActorId &&
      concertId == ticketPreviewConcertId &&
      concert.id == concertId &&
      _store.scope == (concertId: concertId, actorId: actorId, role: role) &&
      (currentScope?.call() ?? _store.scope) == _store.scope;

  TicketSettings? read() {
    _requireAccess();
    return _store._saved;
  }

  @override
  TicketSchedule? readSchedule() => read()?.schedule;

  /// 경로/행위자가 폐기되면 기존 읽기 인터페이스도 더 이상 사용할 수 없다.
  void close() {
    _active = false;
  }

  Map<TicketSettingsField, String> validate(TicketSettingsDraft draft) {
    _requireAccess();
    return validateTicketSettings(draft, now());
  }

  TicketSettings save(TicketSettingsDraft draft) {
    final errors = validate(draft);
    if (errors.isNotEmpty) throw TicketSettingsFailure(errors);
    // 같은 합성 공연 페이지를 동시에 구성해도 먼저 확정된 설정을 덮어쓰지 않는다.
    if (_store._saved case final saved?) return saved;
    final saved = TicketSettings(
      draft: draft,
      schedule: TicketSchedule(
        registrationClosesAt: draft.registrationClosesAt!,
        performanceStartsAt: draft.performanceStartsAt!,
        performanceEndsAt: draft.performanceEndsAt!,
        refundClosesAt: draft.refundClosesAt!,
      ),
    );
    _store._saved = saved;
    return saved;
  }

  void _requireAccess() {
    if (!canEdit) throw const TicketSettingsFailure({}, denied: true);
  }
}

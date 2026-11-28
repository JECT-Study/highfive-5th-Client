import 'package:flutter/foundation.dart';

import '../../data/repositories/ticket_settings_repository.dart';
import '../../models/ticket_role.dart';
import '../../models/ticket_schedule.dart';
import '../../models/ticket_settings.dart';

/// 동기 메모리 명령만 사용한다. 비동기 로딩/실패를 흉내 내지 않는다.
class TicketSettingsViewModel extends ChangeNotifier {
  factory TicketSettingsViewModel.preview({
    required TicketRole role,
    required TicketSettingsConcert concert,
    required String actorId,
  }) => TicketSettingsViewModel(
    TicketSettingsRepository(
      role: role,
      concert: concert,
      actorId: actorId,
      now: DateTime.now,
    ),
  );

  TicketSettingsViewModel(this.repository) {
    if (repository.canEdit) {
      final saved = repository.read();
      _draft =
          saved?.draft ??
          TicketSettingsDraft(
            performanceStartsAt: repository.concert.startsAt,
            performanceEndsAt: repository.concert.endsAt,
            registrationClosesAt: repository.concert.startsAt,
            refundClosesAt: repository.concert.startsAt,
          );
    }
  }

  final TicketSettingsRepository repository;
  TicketPageScope get scope => (
    concertId: repository.concertId,
    actorId: repository.actorId,
    role: repository.role,
  );
  TicketSettingsConcert get concert => repository.concert;
  TicketScheduleSource get scheduleSource => repository;
  TicketSettingsDraft _draft = const TicketSettingsDraft();
  TicketSettingsDraft get draft => _draft;
  Map<TicketSettingsField, String> _errors = {};
  Map<TicketSettingsField, String> get errors => Map.unmodifiable(_errors);
  bool get canEdit => repository.canEdit;
  bool saved = false;

  void update(TicketSettingsDraft value) {
    if (!canEdit) return;
    _draft = value;
    if (_errors.isNotEmpty) _errors = repository.validate(value);
    saved = false;
    notifyListeners();
  }

  bool validate({bool includeDescription = true}) {
    try {
      _errors = repository.validate(_draft);
      if (!includeDescription) {
        _errors.remove(TicketSettingsField.introduction);
        _errors.remove(TicketSettingsField.precautions);
      }
      notifyListeners();
      return _errors.isEmpty;
    } on TicketSettingsFailure catch (failure) {
      _errors = failure.errors;
      notifyListeners();
      return false;
    }
  }

  void beginConfiguration() {
    saved = false;
    _errors = {};
  }

  TicketSettings? save() {
    if (saved) return null;
    try {
      final result = repository.save(_draft);
      _draft = result.draft;
      saved = true;
      _errors = {};
      notifyListeners();
      return result;
    } on TicketSettingsFailure catch (failure) {
      _errors = failure.errors;
      saved = false;
      notifyListeners();
      return null;
    }
  }

  void revoke() => repository.close();

  @override
  void dispose() {
    revoke();
    super.dispose();
  }
}

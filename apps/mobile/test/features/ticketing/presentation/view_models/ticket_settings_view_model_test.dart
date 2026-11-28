import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/ticketing/data/repositories/ticket_settings_repository.dart';
import 'package:highfive/features/ticketing/models/ticket_role.dart';
import 'package:highfive/features/ticketing/models/ticket_settings.dart';
import 'package:highfive/features/ticketing/presentation/view_models/ticket_settings_view_model.dart';

import '../../settings_fixture.dart';

void main() {
  late TicketSettingsRepository repository;
  late TicketSettingsViewModel model;

  setUp(() {
    repository = TicketSettingsRepository(
      role: TicketRole.organizer,
      concert: TicketSettingsConcert.demo,
      actorId: 'demo-host',
      now: () => settingsNow,
    );
    model = TicketSettingsViewModel(repository);
  });
  tearDown(() => model.dispose());

  test('초기 공연 시간을 불러오되 저장 전에는 판매 일정으로 노출하지 않는다', () {
    expect(model.draft.performanceStartsAt, DateTime(2027, 1, 12, 19));
    expect(repository.readSchedule(), isNull);
  });

  test('검증 실패 후 초안을 수정하면 오류를 지우고 저장할 수 있다', () {
    expect(model.save(), isNull);
    expect(model.errors, contains(TicketSettingsField.account));

    model.update(validTicketSettings());
    expect(model.errors, isEmpty);
    expect(model.save(), isNotNull);
    expect(model.saved, isTrue);
  });

  test('연속 저장은 한 번만 완료되고 확정 설정은 나중 초안으로 덮어쓰지 않는다', () {
    model.update(validTicketSettings());
    expect(model.save(), isNotNull);
    expect(model.save(), isNull);

    model.update(model.draft.copyWith(price: '20000'));
    expect(model.saved, isFalse);
    expect(model.save()?.draft.price, '15000');
  });

  test('단계 검증은 저장하지 않고 생성 실패 후 재진입은 같은 설정을 다시 확정한다', () {
    model.update(validTicketSettings());
    expect(model.validate(), isTrue);
    expect(repository.read(), isNull);
    final first = model.save();
    model.beginConfiguration();
    expect(model.save(), same(first));
  });

  test('가격만 고치면 아직 해결하지 않은 계좌 오류는 유지한다', () {
    model.save();
    model.update(model.draft.copyWith(price: '0'));
    expect(model.errors, isNot(contains(TicketSettingsField.price)));
    expect(model.errors, contains(TicketSettingsField.account));
  });
  test('새 ViewModel은 같은 범위 저장소의 저장값을 복원한다', () {
    repository.save(validTicketSettings());
    final reopened = TicketSettingsViewModel(repository);
    addTearDown(reopened.dispose);

    expect(reopened.draft.price, '15000');
    expect(reopened.draft.refundClosesAt, DateTime(2027, 1, 11, 23, 59));
  });
}

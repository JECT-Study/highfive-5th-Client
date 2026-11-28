import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:highfive/app/env.dart';
import 'package:highfive/app/providers.dart';
import 'package:highfive/app/router.dart';
import 'package:highfive/app/routes.dart';
import 'package:highfive/core/error/app_exception.dart';
import 'package:highfive/features/auth/models/session.dart';
import 'package:highfive/features/auth/presentation/view_models/session_view_model.dart';
import 'package:highfive/features/performances/data/repositories/concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/concert_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_participants_repository.dart';
import 'package:highfive/features/performances/data/repositories/fake_concert_repository.dart';
import 'package:highfive/features/performances/models/concert_participant.dart';
import 'package:highfive/features/performances/models/concert_detail.dart';
import 'package:highfive/features/performances/presentation/providers/concert_detail_providers.dart';
import 'package:highfive/features/performances/presentation/providers/concert_participants_providers.dart';
import 'package:highfive/features/performances/presentation/views/concert_band_profile_view.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';
import 'package:highfive/shared/widgets/app_top_bar.dart';
import 'package:highfive/shared/widgets/empty_view.dart';
import 'package:highfive/shared/widgets/error_view.dart';
import 'package:highfive/shared/widgets/loading_view.dart';
import 'package:highfive/shared/widgets/show/show_meta_text.dart';
import 'package:highfive/shared/widgets/show/show_team_avatar.dart';

// 자동 체인이 없는 수동 재시도는 기존의 미인식 403 분기로 검사한다.
// 네트워크 자동 재시도는 별도 타이머 회귀 테스트가 실제 정책대로 검사한다.
const _manualFailure = ApiException(statusCode: 403, code: 'OTHER');

/// 인증 동작은 별도 테스트가 맡고, 실제 라우터의 로그인 이후 경로를 사용한다.
class _SignedInSession extends SessionViewModel {
  @override
  Future<Session?> build() async => const Session(accessToken: 'test');
}

class _HeldParticipants implements ConcertParticipantsRepository {
  final response = Completer<List<ConcertParticipant>>();

  @override
  Future<List<ConcertParticipant>> fetchParticipants(int concertId) =>
      response.future;
}

class _RetryParticipants implements ConcertParticipantsRepository {
  final first = Completer<List<ConcertParticipant>>();
  final secondRequested = Completer<void>();
  final response = Completer<List<ConcertParticipant>>();
  var calls = 0;

  @override
  Future<List<ConcertParticipant>> fetchParticipants(int concertId) {
    calls++;
    if (calls == 2) secondRequested.complete();
    return calls == 1 ? first.future : response.future;
  }
}

class _RetryConcerts implements ConcertRepository {
  final first = Completer<ConcertDetail>();
  final response = Completer<ConcertDetail>();
  var calls = 0;

  @override
  Future<ConcertDetail> fetchDetail(int concertId) {
    calls++;
    return calls == 1 ? first.future : response.future;
  }
}

Future<GoRouter> _mount(
  WidgetTester tester, {
  String? location,
  ConcertParticipantsRepository? participants,
  ConcertRepository? concerts,
}) async {
  tester.view.physicalSize = const Size(320, 812);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        appEnvProvider.overrideWithValue(
          const AppEnv(
            flavor: Flavor.prod,
            apiBaseUrl: 'http://localhost',
            kakaoNativeAppKey: 'test',
            googleIosClientId: 'test',
            googleServerClientId: 'test',
          ),
        ),
        sessionProvider.overrideWith(_SignedInSession.new),
        concertRepositoryProvider.overrideWithValue(
          concerts ?? FakeConcertRepository(),
        ),
        concertParticipantsRepositoryProvider.overrideWithValue(
          participants ?? FakeConcertParticipantsRepository(),
        ),
      ],
      child: Consumer(
        builder: (context, ref, child) => MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: ref.watch(routerProvider),
        ),
      ),
    ),
  );
  final container = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  );
  await container.read(sessionProvider.future);
  final router = container.read(routerProvider);
  router.go(location ?? AppRoutes.showOf('12'));
  await tester.pump();
  await tester.pump();
  return router;
}

Finder get _close => find.descendant(
  of: find.byType(AppTopBar),
  matching: find.byType(AppIconButton),
);

Future<ProviderContainer> _failInitialReads(
  WidgetTester tester,
  _RetryConcerts concerts,
  _RetryParticipants participants,
) async {
  await _mount(
    tester,
    location: AppRoutes.showBandOf('12', '3'),
    concerts: concerts,
    participants: participants,
  );
  final container = ProviderScope.containerOf(
    tester.element(find.byType(ConcertBandProfileView)),
  );
  final detailFailed = Completer<void>();
  final participantsFailed = Completer<void>();
  final detailSubscription = container.listen(concertDetailProvider(12), (
    previous,
    next,
  ) {
    if (next.hasError && !detailFailed.isCompleted) detailFailed.complete();
  });
  final participantsSubscription = container.listen(
    concertParticipantsProvider(12),
    (previous, next) {
      if (next.hasError && !participantsFailed.isCompleted) {
        participantsFailed.complete();
      }
    },
  );
  addTearDown(detailSubscription.close);
  addTearDown(participantsSubscription.close);
  concerts.first.completeError(_manualFailure);
  participants.first.completeError(_manualFailure);
  await Future.wait([detailFailed.future, participantsFailed.future])
      .timeout(const Duration(seconds: 5));
  await tester.pump();
  return container;
}

void main() {
  testWidgets('실제 정보 탭의 밴드를 누르면 프로필로 이동하고 닫으면 같은 공연으로 돌아온다', (tester) async {
    final router = await _mount(tester);
    await tester.pumpAndSettle();
    final band = FakeConcertParticipantsRepository.sample.last;
    final avatar = find.widgetWithText(ShowTeamAvatar, band.name);
    await tester.ensureVisible(avatar);
    await tester.pumpAndSettle();

    await tester.tap(avatar);
    await tester.pumpAndSettle();

    expect(
      router.state.matchedLocation,
      AppRoutes.showBandOf('12', '${band.bandId}'),
    );
    expect(find.byType(ConcertBandProfileView), findsOneWidget);
    expect(find.text(band.name), findsOneWidget);
    expect(find.text(FakeConcertRepository.sample.title), findsOneWidget);
    final metadata = tester
        .widgetList<ShowMetaText>(find.byType(ShowMetaText))
        .map((widget) => widget.items)
        .toList();
    expect(metadata, [
      ['록'],
      ['팀원 4명'],
    ]);
    expect(tester.takeException(), isNull);

    await tester.tap(_close);
    await tester.pumpAndSettle();
    expect(router.state.matchedLocation, AppRoutes.showOf('12'));
    expect(find.byType(ConcertBandProfileView), findsNothing);
  });

  testWidgets('직접 연 프로필은 닫으면 공연 정보로 이동한다', (tester) async {
    final router = await _mount(
      tester,
      location: AppRoutes.showBandOf('12', '3'),
    );
    await tester.pumpAndSettle();

    await tester.tap(_close);
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, AppRoutes.showOf('12'));
  });

  testWidgets('참여 목록이 대기 중이면 프로필 데이터 대신 진행 표시를 보인다', (tester) async {
    final participants = _HeldParticipants();
    await _mount(
      tester,
      location: AppRoutes.showBandOf('12', '3'),
      participants: participants,
    );
    expect(find.byType(LoadingView), findsOneWidget);
    expect(find.byType(ShowMetaText), findsNothing);

    participants.response.complete(FakeConcertParticipantsRepository.sample);
    await tester.pumpAndSettle();
    expect(
      find.text(FakeConcertParticipantsRepository.sample.first.name),
      findsOneWidget,
    );
    expect(find.byType(LoadingView), findsNothing);
  });

  testWidgets('실패 뒤 다시 시도는 요청 중 로딩을 보이고 새 응답을 표시한다', (tester) async {
    final participants = _RetryParticipants();
    await _mount(
      tester,
      location: AppRoutes.showBandOf('12', '3'),
      participants: participants,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConcertBandProfileView)),
    );
    final failed = Completer<void>();
    final subscription = container.listen(concertParticipantsProvider(12), (
      previous,
      next,
    ) {
      if (next.hasError && !failed.isCompleted) failed.complete();
    });
    addTearDown(subscription.close);
    participants.first.completeError(_manualFailure);
    await failed.future.timeout(const Duration(seconds: 5));
    await tester.pump();
    expect(find.byType(ErrorView), findsOneWidget);

    await tester.tap(find.byType(AppButton));
    await tester.pump();
    expect(tester.widget<AppButton>(find.byType(AppButton)).loading, isTrue);
    await tester.tap(find.byType(AppButton));
    expect(participants.calls, 2);
    participants.response.complete(FakeConcertParticipantsRepository.sample);
    await tester.pumpAndSettle();

    expect(find.byType(ErrorView), findsNothing);
    expect(
      find.text(FakeConcertParticipantsRepository.sample.first.name),
      findsOneWidget,
    );
  });

  testWidgets('참여 목록에 없거나 잘못된 밴드 주소는 프로필을 만들어 내지 않는다', (tester) async {
    for (final bandId in ['999', '0x3']) {
      await _mount(tester, location: AppRoutes.showBandOf('12', bandId));
      await tester.pumpAndSettle();
      expect(find.byType(EmptyView), findsOneWidget, reason: bandId);
      expect(find.byType(ShowMetaText), findsNothing, reason: bandId);
    }
  });

  testWidgets('자동 재시도 요청이 진행 중이면 수동 탭으로 세 번째 조회를 보내지 않는다', (tester) async {
    final participants = _RetryParticipants();
    await _mount(
      tester,
      location: AppRoutes.showBandOf('12', '3'),
      participants: participants,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConcertBandProfileView)),
    );
    final failed = Completer<void>();
    final subscription = container.listen(concertParticipantsProvider(12), (
      previous,
      next,
    ) {
      if (next.hasError && !failed.isCompleted) failed.complete();
    });
    addTearDown(subscription.close);
    const error = NetworkException();
    participants.first.completeError(error);
    await failed.future.timeout(const Duration(seconds: 5));
    await tester.pump();

    // SDK의 백오프 타이머 동작 자체를 검사한다. 임의의 대기가 아니라 실제 정책 지연을 진행한다.
    final delay = ProviderContainer.defaultRetry(0, error)!;
    await tester.pump(delay);
    await tester.pump();
    await participants.secondRequested.future.timeout(
      const Duration(seconds: 5),
    );
    expect(participants.calls, 2);

    expect(tester.widget<AppButton>(find.byType(AppButton)).loading, isTrue);
    await tester.tap(find.byType(AppButton));
    await tester.pump();
    final callsAfterTap = participants.calls;
    participants.response.complete(FakeConcertParticipantsRepository.sample);
    await tester.pumpAndSettle();

    expect(callsAfterTap, 2);
    expect(find.byType(ErrorView), findsNothing);
    expect(
      find.text(FakeConcertParticipantsRepository.sample.first.name),
      findsOneWidget,
    );
  });

  testWidgets('재시도한 두 조회 중 하나가 실패해도 나머지가 끝나기 전에는 중복 요청하지 않는다', (tester) async {
    final concerts = _RetryConcerts();
    final participants = _RetryParticipants();
    final container = await _failInitialReads(tester, concerts, participants);

    await tester.tap(find.byType(AppButton));
    await tester.pump();
    final secondError = Completer<void>();
    final subscription = container.listen(concertParticipantsProvider(12), (
      previous,
      next,
    ) {
      if (next.hasError && !next.isLoading && !secondError.isCompleted) {
        secondError.complete();
      }
    });
    addTearDown(subscription.close);
    participants.response.completeError(_manualFailure);
    await secondError.future.timeout(const Duration(seconds: 5));
    await tester.pump();

    expect(tester.widget<AppButton>(find.byType(AppButton)).loading, isTrue);
    await tester.tap(find.byType(AppButton));
    expect(concerts.calls, 2);
    expect(participants.calls, 2);

    concerts.response.complete(FakeConcertRepository.sample);
    await tester.pumpAndSettle();
    expect(tester.widget<AppButton>(find.byType(AppButton)).loading, isFalse);
  });

  testWidgets('다른 조회만 재시도하고 최초 응답을 기다리는 요청은 그대로 기다린다', (tester) async {
    final concerts = _RetryConcerts();
    final participants = _RetryParticipants();
    await _mount(
      tester,
      location: AppRoutes.showBandOf('12', '3'),
      concerts: concerts,
      participants: participants,
    );
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConcertBandProfileView)),
    );
    final failed = Completer<void>();
    final subscription = container.listen(concertParticipantsProvider(12), (
      previous,
      next,
    ) {
      if (next.hasError && !failed.isCompleted) failed.complete();
    });
    addTearDown(subscription.close);
    participants.first.completeError(_manualFailure);
    await failed.future.timeout(const Duration(seconds: 5));
    await tester.pump();

    await tester.tap(find.byType(AppButton));
    await tester.pump();

    expect(concerts.calls, 1);
    expect(participants.calls, 2);
    participants.response.complete(FakeConcertParticipantsRepository.sample);
    await tester.pump();
    expect(find.byType(LoadingView), findsOneWidget);
    concerts.first.complete(FakeConcertRepository.sample);
    await tester.pumpAndSettle();
    expect(find.byType(ErrorView), findsNothing);
    expect(concerts.calls, 1);
  });

  testWidgets('재시도 도중 접근 거부·삭제를 알면 다른 응답을 기다리지 않고 복귀한다', (tester) async {
    for (final error in [
      const ApiException(statusCode: 403, code: 'AUTH_005'),
      const ApiException(statusCode: 404, code: 'CONCERT_001'),
    ]) {
      final concerts = _RetryConcerts();
      final participants = _RetryParticipants();
      final container = await _failInitialReads(tester, concerts, participants);
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      final terminal = Completer<void>();
      final subscription = container.listen(concertParticipantsProvider(12), (
        previous,
        next,
      ) {
        if (next.error is ApiException && !terminal.isCompleted) {
          terminal.complete();
        }
      });
      addTearDown(subscription.close);
      participants.response.completeError(error);
      await terminal.future.timeout(const Duration(seconds: 5));
      await tester.pump();

      expect(tester.widget<AppButton>(find.byType(AppButton)).loading, isFalse);
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(concerts.response.isCompleted, isFalse);
      expect(
        container.read(routerProvider).state.matchedLocation,
        AppRoutes.showOf('12'),
      );
      concerts.response.complete(FakeConcertRepository.sample);
      await tester.pumpAndSettle();
      expect(
        container.read(routerProvider).state.matchedLocation,
        AppRoutes.showOf('12'),
      );
      expect(find.byType(ConcertBandProfileView), findsNothing);
    }
  });

  testWidgets('접근 거부는 재시도 대신 이전 화면으로 이동한다', (tester) async {
    final router = await _mount(
      tester,
      location: AppRoutes.showBandOf('12', '3'),
      participants: FakeConcertParticipantsRepository(
        forbiddenConcertIds: {12},
      ),
    );
    expect(find.byType(ErrorView), findsOneWidget);

    await tester.tap(find.byType(AppButton));
    await tester.pumpAndSettle();

    expect(router.state.matchedLocation, AppRoutes.showOf('12'));
    expect(find.byType(ShowMetaText), findsNothing);
  });

  testWidgets('최소 참여자 projection에는 인원을 지어내지 않는다', (tester) async {
    await _mount(
      tester,
      location: AppRoutes.showBandOf('12', '3'),
      participants: FakeConcertParticipantsRepository(
        participants: {
          12: [
            const ConcertParticipant(bandId: 3, name: '단촐한 밴드', isHost: true),
          ],
        },
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('단촐한 밴드'), findsOneWidget);
    expect(find.byType(ShowMetaText), findsNothing);
  });
}

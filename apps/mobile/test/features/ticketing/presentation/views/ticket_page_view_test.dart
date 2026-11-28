import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/ticketing/data/repositories/ticket_page_repository.dart';
import 'package:highfive/features/ticketing/models/ticket_application_page.dart';
import 'package:highfive/features/ticketing/models/ticket_role.dart';
import 'package:highfive/features/ticketing/presentation/providers/ticket_page_providers.dart';
import 'package:highfive/features/ticketing/presentation/view_models/ticket_page_view_model.dart';
import 'package:highfive/features/ticketing/presentation/views/ticket_page_view.dart';
import 'package:highfive/shared/theme/app_theme.dart';
import 'package:highfive/shared/widgets/app_button.dart';

const _boundaryKey = ValueKey('ticket_page_capture');
const _host = (
  concertId: ticketPreviewConcertId,
  actorId: ticketPreviewActorId,
  role: TicketRole.organizer,
);

class _ControlledRepository implements TicketPageRepository {
  var read = Completer<TicketApplicationPage?>();
  final write = Completer<TicketApplicationPage>();

  @override
  Stream<TicketApplicationPage> watch(TicketPageScope scope) =>
      const Stream.empty();

  @override
  Future<TicketApplicationPage?> find(TicketPageScope scope) => read.future;

  @override
  Future<TicketApplicationPage> create(TicketPageScope scope) => write.future;
}

Future<void> _mount(
  WidgetTester tester, {
  TicketPageRepository? repository,
  TicketRole role = TicketRole.organizer,
  String actorId = ticketPreviewActorId,
  double width = 390,
}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (repository != null)
          ticketPageRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: RepaintBoundary(
          key: _boundaryKey,
          child: TicketPageView(role: role, actorId: actorId),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _capture(WidgetTester tester, String name) async {
  final directory = Platform.environment['TICKET_EVIDENCE_DIR'];
  if (directory == null) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_boundaryKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    await Directory(directory).create(recursive: true);
    await File('$directory/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    final font = FontLoader('Pretendard');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      font.addFont(
        rootBundle.load('assets/fonts/pretendard/Pretendard-$weight.otf'),
      );
    }
    await font.load();
  });

  for (final width in [320.0, 390.0]) {
    testWidgets('주최 대표자는 $width 폭에서 생성 버튼으로 페이지를 만든다', (tester) async {
      await _mount(tester, width: width);
      await _capture(tester, 'empty-${width.toInt()}');
      expect(find.byKey(TicketPageView.createKey), findsOneWidget);
      await tester.tap(find.byKey(TicketPageView.createKey));
      await tester.pumpAndSettle();
      expect(find.byKey(TicketPageView.createdKey), findsOneWidget);
      expect(find.byKey(TicketPageView.createKey), findsNothing);
      expect(tester.takeException(), isNull);
      await _capture(tester, 'created-${width.toInt()}');
    });
  }

  for (final width in [320.0, 390.0]) {
    testWidgets('$width 조회 중에는 빈 생성 화면을 표시하지 않는다', (tester) async {
      final repository = _ControlledRepository();
      await _mount(tester, repository: repository, width: width);
      expect(find.byKey(TicketPageView.loadingKey), findsOneWidget);
      expect(find.byKey(TicketPageView.createKey), findsNothing);
      await _capture(tester, 'loading-${width.toInt()}');
      // 성공 대기가 아니라 진행 표시 애니메이션의 중간 프레임을 기록한다.
      await tester.pump(const Duration(milliseconds: 600));
      await _capture(tester, 'loading-mid-${width.toInt()}');
      repository.read.complete(null);
      await tester.pumpAndSettle();
    });

    testWidgets('$width 생성 보류 중 버튼이 비활성이며 완료하면 생성 화면으로 바뀐다', (tester) async {
      final repository = _ControlledRepository()..read.complete(null);
      await _mount(tester, repository: repository, width: width);
      await tester.tap(find.byKey(TicketPageView.createKey));
      await tester.pump();
      final button = tester.widget<AppButton>(
        find.byKey(TicketPageView.createKey),
      );
      expect(button.loading, isTrue);
      expect(button.onPressed, isNull);
      await _capture(tester, 'creating-${width.toInt()}');
      repository.write.complete(
        const TicketApplicationPage(concertId: ticketPreviewConcertId),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(TicketPageView.createdKey), findsOneWidget);
    });

    testWidgets('$width 조회 오류를 표시하고 재조회 성공 뒤 생성 버튼을 제공한다', (tester) async {
      final repository = _ControlledRepository();
      await _mount(tester, repository: repository, width: width);
      repository.read.completeError(
        const TicketPageFailure(TicketPageFailureReason.unavailable),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(TicketPageView.retryKey), findsOneWidget);
      expect(find.byKey(TicketPageView.createKey), findsNothing);
      await _capture(tester, 'error-${width.toInt()}');
      repository.read = Completer<TicketApplicationPage?>()..complete(null);
      await tester.tap(find.byKey(TicketPageView.retryKey));
      await tester.pumpAndSettle();
      expect(find.byKey(TicketPageView.createKey), findsOneWidget);
    });

    testWidgets('$width 생성 결과 미확정이면 빈 상태와 생성 버튼 대신 재조회만 보인다', (tester) async {
      final repository = _ControlledRepository()..read.complete(null);
      await _mount(tester, repository: repository, width: width);
      await tester.tap(find.byKey(TicketPageView.createKey));
      await tester.pump();
      await tester.pump(TicketPageViewModel.requestTimeout);
      await tester.pump();
      expect(find.byKey(TicketPageView.unknownKey), findsOneWidget);
      expect(find.byKey(TicketPageView.createKey), findsNothing);
      await _capture(tester, 'unknown-${width.toInt()}');
      repository.write.complete(
        const TicketApplicationPage(concertId: ticketPreviewConcertId),
      );
    });
  }

  testWidgets('기본 outsider와 일반 멤버는 생성 동작에 접근하지 못한다', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(theme: AppTheme.light, home: const TicketPageView()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(TicketPageView.deniedKey), findsOneWidget);
    expect(find.byKey(TicketPageView.createKey), findsNothing);
    await tester.pumpWidget(const SizedBox());
    for (final width in [320.0, 390.0]) {
      for (final actorId in ['demo-guest', 'demo-member-a']) {
        await tester.pumpWidget(const SizedBox());
        await _mount(
          tester,
          role: ticketPreviewRoles[actorId]!,
          actorId: actorId,
          width: width,
        );
        await tester.pumpAndSettle();
        expect(find.byKey(TicketPageView.deniedKey), findsOneWidget);
        expect(find.byKey(TicketPageView.createKey), findsNothing);
        final name = actorId == 'demo-guest' ? 'outsider' : 'member';
        await _capture(tester, '$name-${width.toInt()}');
      }
    }
  });

  for (final confirmed in [false, true]) {
    testWidgets('설정 화면이 가려진 뒤 $confirmed로 돌아와도 로딩이 끝난다', (tester) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            navigatorKey: navigator,
            home: TicketPageView(
              role: TicketRole.organizer,
              onConfigure: () async =>
                  await navigator.currentState!.push<bool>(
                    MaterialPageRoute<bool>(
                      builder: (context) => Scaffold(
                        body: TextButton(
                          key: const ValueKey('configure_done'),
                          onPressed: () => Navigator.of(context).pop(confirmed),
                          child: const Text('돌아가기'),
                        ),
                      ),
                    ),
                  ) ??
                  false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TicketPageView.createKey));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('configure_done')));
      await tester.pumpAndSettle();
      if (confirmed) {
        expect(find.byKey(TicketPageView.createdKey), findsOneWidget);
      } else {
        final button = tester.widget<AppButton>(
          find.byKey(TicketPageView.createKey),
        );
        expect(button.loading, isFalse);
        expect(button.onPressed, isNotNull);
      }
    });
  }

  for (final returnToHost in [false, true]) {
    testWidgets('프레임 전 actor 전환과 복귀 $returnToHost 뒤 콜백은 첫 쓰기를 못 한다', (
      tester,
    ) async {
      final repository = PreviewTicketPageRepository();
      addTearDown(repository.dispose);
      final container = ProviderContainer(
        overrides: [ticketPageRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      container.listen(ticketPageViewModelProvider(_host), (_, _) {});
      final actor = ValueNotifier<TicketPageScope>(_host);
      addTearDown(actor.dispose);
      final configuration = Completer<bool>();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: TicketPageView(
              actorScope: actor,
              onConfigure: () => configuration.future,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(TicketPageView.createKey));
      await tester.pump();
      actor.value = (
        concertId: ticketPreviewConcertId,
        actorId: 'demo-member-a',
        role: TicketRole.member,
      );
      if (returnToHost) actor.value = _host;
      // actor 전환과 완료 사이에 프레임을 돌리지 않는다.
      configuration.complete(true);
      await tester.pumpAndSettle();
      expect(await repository.find(_host), isNull);
      expect(find.byKey(TicketPageView.createdKey), findsNothing);
    });
  }

  for (final returnToHost in [false, true]) {
    testWidgets('누르는 중 전환과 복귀 $returnToHost 후 손을 떼도 설정을 열지 않는다', (
      tester,
    ) async {
      final repository = PreviewTicketPageRepository();
      addTearDown(repository.dispose);
      final container = ProviderContainer(
        overrides: [ticketPageRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
      container.listen(ticketPageViewModelProvider(_host), (_, _) {});
      final actor = ValueNotifier<TicketPageScope>(_host);
      addTearDown(actor.dispose);
      var configurations = 0;
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light,
            home: TicketPageView(
              actorScope: actor,
              onConfigure: () async {
                configurations++;
                return true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(TicketPageView.createKey)),
      );
      actor.value = (
        concertId: ticketPreviewConcertId,
        actorId: 'demo-guest',
        role: TicketRole.outsider,
      );
      if (returnToHost) actor.value = _host;
      // down → 전환 → up 사이에 화면을 다시 그리지 않는다.
      await gesture.up();
      await tester.pumpAndSettle();
      expect(configurations, 0);
      expect(await repository.find(_host), isNull);
    });
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/features/performances/data/repositories/concert_edit_repository.dart';
import 'package:highfive/features/performances/models/concert_edit_failure.dart';
import 'package:highfive/features/performances/models/concert_edit_values.dart';
import 'package:highfive/features/performances/presentation/view_models/concert_edit_view_model.dart';

import '../../edit_fixture.dart';

class _Repository implements ConcertEditRepository {
  int writes = 0;
  int reads = 0;
  ConcertEditValues? written;
  Future<void> Function()? saveAction;
  Future<ConcertEditSnapshot> Function()? readAction;

  @override
  Future<void> save(ConcertEditValues values) async {
    writes++;
    written = values;
    await saveAction?.call();
  }

  @override
  Future<ConcertEditSnapshot> reload() async {
    reads++;
    return await readAction?.call() ?? editSnapshot();
  }
}

void main() {
  late ProviderContainer container;
  late _Repository repository;
  late ConcertEditEntry entry;
  late bool sessionCurrent;
  void start({bool participant = true}) {
    entry = ConcertEditEntry(
      initial: editSnapshot(participant: participant),
      repository: repository,
      isSessionCurrent: () => sessionCurrent,
    );
    container.listen(concertEditProvider(entry), (_, _) {});
  }

  setUp(() {
    container = ProviderContainer();
    repository = _Repository();
    sessionCurrent = true;
  });
  tearDown(() => container.dispose());

  test('저장 중 중복 탭과 성공 뒤 같은 version 재전송을 막는다', () async {
    start();
    final completed = Completer<void>();
    repository.saveAction = () => completed.future;
    final vm = container.read(concertEditProvider(entry).notifier);
    final form = ConcertEditForm(entry.initial.values)..title = '수정한 제목';
    final first = vm.submit(form);
    await vm.submit(form);
    expect(repository.writes, 1);
    expect(
      container.read(concertEditProvider(entry)).status,
      ConcertEditStatus.saving,
    );
    completed.complete();
    await first;
    await vm.submit(form);
    expect(repository.writes, 1);
    expect(
      container.read(concertEditProvider(entry)).status,
      ConcertEditStatus.saved,
    );
    expect(
      repository.written!.posterImageUrl,
      'https://files.test/existing-poster.png',
    );
  });

  test('비참여자는 ViewModel을 직접 호출해도 저장할 수 없다', () async {
    start(participant: false);
    await container
        .read(concertEditProvider(entry).notifier)
        .submit(ConcertEditForm(entry.initial.values));
    expect(repository.writes, 0);
  });

  test('잘못된 폼은 서버 호출 전에 해당 필드 오류를 만든다', () async {
    start();
    final form = ConcertEditForm(entry.initial.values)..title = ' ';
    await container.read(concertEditProvider(entry).notifier).submit(form);
    expect(repository.writes, 0);
    expect(container.read(concertEditProvider(entry)).fields.keys, ['title']);
  });

  test('충돌하면 최신 값·권한·version을 다시 읽어 오래된 입력을 교체한다', () async {
    start();
    repository.saveAction = () async =>
        throw const ConcertEditFailure(ConcertEditFailureKind.conflict);
    repository.readAction = () async =>
        editSnapshot(values: {...editJson(), 'title': '최신 제목', 'version': 9});
    await container
        .read(concertEditProvider(entry).notifier)
        .submit(ConcertEditForm(entry.initial.values));
    final state = container.read(concertEditProvider(entry));
    expect(repository.reads, 1);
    expect(state.snapshot.values.title, '최신 제목');
    expect(state.snapshot.values.version, 9);
    expect(state.revision, 1);
    expect(state.canEdit, isTrue);
  });

  test('충돌 재조회 실패 시 오래된 값으로 재전송하지 않는다', () async {
    start();
    repository.saveAction = () async =>
        throw const ConcertEditFailure(ConcertEditFailureKind.conflict);
    repository.readAction = () async =>
        throw const ConcertEditFailure(ConcertEditFailureKind.uncertain);
    final vm = container.read(concertEditProvider(entry).notifier);
    final form = ConcertEditForm(entry.initial.values);
    await vm.submit(form);
    await vm.submit(form);
    expect(repository.writes, 1);
    expect(
      container.read(concertEditProvider(entry)).status,
      ConcertEditStatus.needsReload,
    );
  });

  for (final kind in [
    ConcertEditFailureKind.authentication,
    ConcertEditFailureKind.forbidden,
    ConcertEditFailureKind.missing,
    ConcertEditFailureKind.uncertain,
  ]) {
    test('${kind.name} 저장 오류 후에는 자동·수동 재전송하지 않는다', () async {
      start();
      repository.saveAction = () async => throw ConcertEditFailure(kind);
      final vm = container.read(concertEditProvider(entry).notifier);
      final form = ConcertEditForm(entry.initial.values);
      await vm.submit(form);
      await vm.submit(form);
      expect(repository.writes, 1);
      expect(container.read(concertEditProvider(entry)).failure, kind);
      expect(repository.reads, 0);
    });
  }

  test('검증 오류는 입력을 유지한 채 필드 사유를 표시하고 수정 제출을 허용한다', () async {
    start();
    repository.saveAction = () async => throw const ConcertEditFailure(
      ConcertEditFailureKind.invalid,
      fields: {'title': '서버 사유'},
    );
    final vm = container.read(concertEditProvider(entry).notifier);
    await vm.submit(ConcertEditForm(entry.initial.values));
    expect(container.read(concertEditProvider(entry)).fields, {
      'title': '서버 사유',
    });
    expect(container.read(concertEditProvider(entry)).canEdit, isTrue);
  });

  test('저장 전 계정 전환은 호출을 막는다', () async {
    start();
    sessionCurrent = false;
    await container
        .read(concertEditProvider(entry).notifier)
        .submit(ConcertEditForm(entry.initial.values));
    expect(repository.writes, 0);
    expect(
      container.read(concertEditProvider(entry)).failure,
      ConcertEditFailureKind.authentication,
    );
  });

  test('요청 도중 세션 전환 시 이전 응답을 성공으로 사용하지 않는다', () async {
    start();
    final completed = Completer<void>();
    repository.saveAction = () => completed.future;
    final future = container
        .read(concertEditProvider(entry).notifier)
        .submit(ConcertEditForm(entry.initial.values));
    sessionCurrent = false;
    completed.complete();
    await future;
    expect(
      container.read(concertEditProvider(entry)).status,
      ConcertEditStatus.blocked,
    );
  });

  test('닫힌 화면의 늦은 응답은 새 상태에 반영하지 않는다', () async {
    start();
    final completed = Completer<void>();
    repository.saveAction = () => completed.future;
    final future = container
        .read(concertEditProvider(entry).notifier)
        .submit(ConcertEditForm(entry.initial.values));
    container.invalidate(concertEditProvider(entry));
    completed.complete();
    await future;
    expect(
      container.read(concertEditProvider(entry)).status,
      ConcertEditStatus.editing,
    );
  });
}

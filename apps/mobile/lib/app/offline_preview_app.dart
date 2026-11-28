import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/performances/data/repositories/offline_concert_repository.dart';
import '../features/performances/models/concert_draft.dart';
import '../features/performances/presentation/providers/concert_providers.dart';
import '../features/performances/presentation/view_models/concert_edit_view_model.dart';
import '../features/performances/presentation/views/concert_creation_view.dart';
import '../features/performances/presentation/views/concert_edit_view.dart';
import '../shared/theme/app_spacing.dart';
import '../shared/theme/app_theme.dart';
import '../shared/theme/app_typography.dart';
import '../shared/widgets/app_button.dart';
import '../shared/widgets/app_top_bar.dart';
import 'env.dart';

void requireOfflinePreview({required Flavor flavor, required bool debug}) {
  if (flavor != Flavor.dev || !debug) {
    throw UnsupportedError('오프라인 미리보기는 dev/debug에서만 실행할 수 있습니다.');
  }
}

/// 인증 SDK·DI·secure storage·Dio를 만들지 않는 명시적 시작점.
class OfflinePreviewApp extends StatefulWidget {
  const OfflinePreviewApp({super.key});

  @override
  State<OfflinePreviewApp> createState() => _OfflinePreviewAppState();
}

class _OfflinePreviewAppState extends State<OfflinePreviewApp> {
  final _store = OfflineConcertRepository();

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [concertRepositoryProvider.overrideWithValue(_store)],
    child: MaterialApp(
      title: 'highfive 오프라인 공연 흐름',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery.withNoTextScaling(
        child: Banner(
          message: 'OFFLINE DEV',
          location: BannerLocation.topEnd,
          child: child!,
        ),
      ),
      home: _OfflineHome(store: _store),
    ),
  );
}

class _OfflineHome extends StatefulWidget {
  const _OfflineHome({required this.store});
  final OfflineConcertRepository store;

  @override
  State<_OfflineHome> createState() => _OfflineHomeState();
}

class _OfflineHomeState extends State<_OfflineHome> {
  late HostBand _band = widget.store.hostBands.first;
  bool _opening = false;

  Future<void> _detail(int id) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _OfflineDetail(store: widget.store, id: id),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _create() async {
    if (_opening) return;
    _opening = true;
    final id = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (context) => ConcertCreationView(
          hostBand: _band,
          onCreated: (id) => Navigator.of(context).pop(id),
          onClose: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (!mounted) return;
    _opening = false;
    if (id != null) await _detail(id);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const AppTopBar(title: '홈'),
    body: ListView(
      padding: const EdgeInsets.all(AppSpacing.x5),
      children: [
        Text(
          '오프라인 공연 흐름 · 서버와 연결하지 않아요',
          style: context.textStyles.body1SemiBold,
        ),
        const SizedBox(height: AppSpacing.x2),
        const Text('밴드와 대표자 역할은 QA 예시예요. 앱을 종료하면 공연이 사라져요.'),
        const SizedBox(height: AppSpacing.x6),
        DropdownButtonFormField<HostBand>(
          key: const ValueKey('offline_hostBand'),
          initialValue: _band,
          isExpanded: true,
          decoration: const InputDecoration(labelText: '주최 밴드 · 대표자 예시'),
          items: [
            for (final band in widget.store.hostBands)
              DropdownMenuItem(value: band, child: Text(band.name)),
          ],
          onChanged: (band) {
            if (band != null) setState(() => _band = band);
          },
        ),
        const SizedBox(height: AppSpacing.x5),
        AppButton(
          key: const ValueKey('offline_create'),
          label: '합동공연 만들기',
          onPressed: _create,
        ),
        const SizedBox(height: AppSpacing.x8),
        Text('내가 만든 공연', style: context.textStyles.title1Bold),
        if (widget.store.ids.isEmpty) const Text('아직 만든 공연이 없어요.'),
        for (final id in widget.store.ids)
          ListTile(
            key: ValueKey('offline_concert_$id'),
            title: Text(widget.store.snapshot(id).values.title),
            subtitle: Text(widget.store.hostOf(id).name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _detail(id),
          ),
      ],
    ),
  );
}

class _OfflineDetail extends StatefulWidget {
  const _OfflineDetail({required this.store, required this.id});
  final OfflineConcertRepository store;
  final int id;

  @override
  State<_OfflineDetail> createState() => _OfflineDetailState();
}

class _OfflineDetailState extends State<_OfflineDetail> {
  bool _editing = false;

  Future<void> _edit() async {
    if (_editing) return;
    _editing = true;
    final repository = widget.store.edit(widget.id);
    final snapshot = await repository.reload();
    if (!mounted) return;
    final entry = ConcertEditEntry(
      initial: snapshot,
      repository: repository,
      isSessionCurrent: () => mounted,
      offline: true,
    );
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => ConcertEditView(
          entry: entry,
          onClose: () => Navigator.of(context).pop(false),
          onSaved: () => Navigator.of(context).pop(true),
        ),
      ),
    );
    if (mounted) setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = widget.store.snapshot(widget.id);
    final values = snapshot.values;
    return Scaffold(
      appBar: AppTopBar(
        title: '공연 정보',
        leading: AppIconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          tooltip: '홈으로',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.x5),
        children: [
          const Text('오프라인에서 만든 공연 · 실제 공연 상세 API 아님'),
          const SizedBox(height: AppSpacing.x6),
          Text(
            values.title,
            key: const ValueKey('offline_detailTitle'),
            style: context.textStyles.title1Bold,
          ),
          const SizedBox(height: AppSpacing.x4),
          Text(widget.store.hostOf(widget.id).name),
          Text(
            snapshot.genres
                .where((genre) => values.genres.contains(genre.code))
                .map((genre) => genre.name)
                .join(' · '),
          ),
          Text('모집 ${values.recruitTeamCount}팀 · 주최 팀 제외'),
          Text('날짜 ${values.performDate ?? '미정'}'),
          Text('시간 ${values.startTime ?? '미정'} ~ ${values.endTime ?? '미정'}'),
          Text('장소 ${values.place ?? '미정'}'),
          if (values.address != null) Text(values.address!),
          Text(
            '전체 대관비 ${values.rentalFee == null ? '미정' : '${values.rentalFee}원'}',
          ),
          const SizedBox(height: AppSpacing.x8),
          AppButton(
            key: const ValueKey('offline_edit'),
            label: '공연 정보 수정',
            onPressed: _edit,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_radius.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_icon.dart';
import '../../../../shared/widgets/app_top_bar.dart';
import '../../../../shared/widgets/empty_view.dart';
import '../../../../shared/widgets/error_view.dart';
import '../../../../shared/widgets/loading_view.dart';
import '../../../../shared/widgets/show/show_meta_text.dart';
import '../../models/concert_genre_label.dart';
import '../providers/concert_band_profile_providers.dart';
import '../providers/concert_detail_providers.dart';
import '../providers/concert_participants_providers.dart';

/// 정보 탭의 참여 밴드를 누르면 여는 밴드 프로필 (Figma `내밴드프로필` 2217:124048, 읽기 전용).
///
/// 참여 목록(라인업 조회 1.4)이 주는 사진·이름·장르·팀원 수와 함께하는 공연만 보인다.
/// 밴드 소개·사진·우리 밴드 공연·팀원·SNS는 밴드 프로필 API가 없어 그리지 않는다.
class ConcertBandProfileView extends ConsumerStatefulWidget {
  const ConcertBandProfileView({
    super.key,
    required this.concertId,
    required this.bandId,
    required this.onClose,
  });

  final int? concertId;
  final int? bandId;
  final VoidCallback onClose;

  @override
  ConsumerState<ConcertBandProfileView> createState() =>
      _ConcertBandProfileViewState();
}

class _ConcertBandProfileViewState
    extends ConsumerState<ConcertBandProfileView> {
  var _retryingDetail = false;
  var _retryingParticipants = false;

  bool get _retrying => _retryingDetail || _retryingParticipants;

  @override
  Widget build(BuildContext context) {
    final concertId = widget.concertId;
    final bandId = widget.bandId;
    var automaticRetrying = false;
    if (concertId != null && bandId != null) {
      final detail = ref.watch(concertDetailProvider(concertId));
      final participants = ref.watch(concertParticipantsProvider(concertId));
      automaticRetrying = detail.retrying || participants.retrying;
      ref.listen(concertDetailProvider(concertId), (previous, next) {
        if (_retryingDetail && (!next.isLoading || next.retrying)) {
          setState(() => _retryingDetail = false);
        }
      });
      ref.listen(concertParticipantsProvider(concertId), (previous, next) {
        if (_retryingParticipants && (!next.isLoading || next.retrying)) {
          setState(() => _retryingParticipants = false);
        }
      });
    }
    final profile = concertId == null || bandId == null
        ? const AsyncData<ConcertBandProfile?>(null)
        : ref.watch(
            concertBandProfileProvider((concertId: concertId, bandId: bandId)),
          );
    return Scaffold(
      appBar: AppTopBar(
        title: '밴드 프로필',
        leading: AppIconButton(
          icon: const AppIcon(AppIcons.close),
          tooltip: '닫기',
          onPressed: widget.onClose,
        ),
      ),
      body: SafeArea(
        child: profile.when(
          loading: () => const LoadingView(),
          error: (error, _) {
            final message = switch (error) {
              ApiException(statusCode: 403, code: 'AUTH_005') =>
                '이 공연에 참여한 팀만 볼 수 있어요.',
              ApiException(statusCode: 404, code: 'CONCERT_001') =>
                '공연을 찾을 수 없어요. 삭제됐거나 주소가 바뀌었을 수 있어요.',
              _ => null,
            };
            return ErrorView(
              message: message ?? '밴드 프로필을 불러오지 못했어요. 다시 시도해 주세요.',
              actionLabel: message == null ? '다시 시도' : '이전 화면으로',
              loading: message == null && (_retrying || automaticRetrying),
              onAction: message != null || concertId == null
                  ? widget.onClose
                  : () {
                      if (_retrying) return;
                      final detailProvider = concertDetailProvider(concertId);
                      final participantsProvider = concertParticipantsProvider(
                        concertId,
                      );
                      final detail = ref.read(detailProvider);
                      final participants = ref.read(participantsProvider);
                      // SDK는 타이머 대기와 실제 자동 요청 중 상태를 구분하지 않는다.
                      // 자동 재시도 체인 전체에서 수동 invalidate를 막는다.
                      if (detail.retrying || participants.retrying) return;
                      final waitingDetail = detail.isLoading;
                      final waitingParticipants = participants.isLoading;
                      setState(() {
                        _retryingDetail = waitingDetail || detail.hasError;
                        _retryingParticipants =
                            waitingParticipants || participants.hasError;
                      });
                      if (detail.hasError && !waitingDetail) {
                        ref.invalidate(detailProvider);
                      }
                      if (participants.hasError && !waitingParticipants) {
                        ref.invalidate(participantsProvider);
                      }
                    },
            );
          },
          data: (profile) => profile == null
              ? const EmptyView(message: '이 공연에 참여 중인 밴드를 찾지 못했어요.')
              : _Profile(profile: profile),
        ),
      ),
    );
  }
}

/// Figma `ProfileArea`: 사진·이름·정보 두 줄과 함께하는 공연.
class _Profile extends StatelessWidget {
  const _Profile({required this.profile});

  final ConcertBandProfile profile;

  static const _avatarSize = 80.0; // Figma: 밴드 프로필 사진 지름

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final band = profile.band;
    final imageUrl = band.profileImageUrl;
    final genres = band.genres.map(concertGenreLabel).nonNulls.toList();
    return ListView(
      // Figma: 상단 바 아래 4, 좌우 20.
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x5,
        AppSpacing.x1,
        AppSpacing.x5,
        AppSpacing.x5,
      ),
      children: [
        Row(
          spacing: AppSpacing.x4,
          children: [
            ClipOval(
              child: SizedBox.square(
                dimension: _avatarSize,
                child: ColoredBox(
                  color: colors.fillStrong,
                  child: imageUrl == null
                      ? null
                      : Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const SizedBox.expand(),
                        ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.x2,
                children: [
                  Text(
                    band.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.title1Bold.copyWith(
                      color: colors.labelNormal,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: AppSpacing.x1_5,
                    children: [
                      if (genres.isNotEmpty) ShowMetaText(genres),
                      if (band.memberCount case final count?)
                        ShowMetaText(['팀원 $count명']),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.x5),
        _ProfileNotice(label: '함께하는 공연', value: profile.concertTitle),
      ],
    );
  }
}

/// Figma `ProfileNotice` (공연페이지 2034:15430). 회색 띠 안의 이름표와 굵은 값 한 줄.
/// 값이 길면 끝을 말줄임표로 줄이고, 이름표는 줄이지 않는다.
class _ProfileNotice extends StatelessWidget {
  const _ProfileNotice({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.backgroundAlternative,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x2_5,
        ),
        child: Row(
          spacing: AppSpacing.x2,
          children: [
            // Figma: 이름표 #858586 → 가장 가까운 의미 색, 값 #0B0B0C = gray800.
            Text(
              label,
              style: textStyles.caption1Regular.copyWith(
                color: colors.labelAlternative,
              ),
            ),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textStyles.caption1SemiBold.copyWith(
                  color: colors.gray800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

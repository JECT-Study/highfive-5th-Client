import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../models/concert_participant.dart';
import 'concert_detail_providers.dart';
import 'concert_participants_providers.dart';

/// 밴드 프로필 화면에 보일 값. [concertTitle]은 Figma `함께하는 공연` 칸에 쓴다.
typedef ConcertBandProfile = ({ConcertParticipant band, String concertTitle});

/// 공연 [concertId]에 참여한 밴드 [bandId]의 프로필.
/// 정보 탭과 같은 참여 목록·공연 상세를 구독한다. 별도 roster나 프로필 요청은 만들지 않는다.
///
/// 참여 목록에 없는 밴드(빠졌거나 주소가 잘못됨)는 null이다. 화면은 '찾을 수 없음'으로 보인다.
final concertBandProfileProvider = Provider.autoDispose
    .family<AsyncValue<ConcertBandProfile?>, ({int concertId, int bandId})>(
      (ref, key) {
        final participants = ref.watch(
          concertParticipantsProvider(key.concertId),
        );
        final concert = ref.watch(concertDetailProvider(key.concertId));
        // 어느 조회에서든 확정된 접근 거부/삭제는 일시적인 다른 오류보다 먼저 처리한다.
        for (final source in [concert, participants]) {
          if (source case AsyncValue(:final error?, :final stackTrace?)
              when error is ApiException &&
                  ((error.statusCode == 403 && error.code == 'AUTH_005') ||
                      (error.statusCode == 404 &&
                          error.code == 'CONCERT_001'))) {
            return AsyncError(error, stackTrace);
          }
        }
        if (concert.value case final detail? when detail.myBandIds.isEmpty) {
          return AsyncError(
            const ApiException(statusCode: 403, code: 'AUTH_005'),
            StackTrace.current,
          );
        }
        // 갱신 실패 뒤에도 이전 프로필을 보여 주지 않는다.
        // 자동 재시도 대기 중에도 원래 오류를 알린다. 수동 재시도의 진행 표시는 화면이 맡는다.
        if (participants case AsyncValue(:final error?, :final stackTrace?)) {
          return AsyncError(error, stackTrace);
        }
        if (concert case AsyncValue(:final error?, :final stackTrace?)) {
          return AsyncError(error, stackTrace);
        }
        if (participants.isLoading || concert.isLoading) {
          return const AsyncLoading();
        }
        final detail = concert.requireValue;
        final band = participants.requireValue
            .where((participant) => participant.bandId == key.bandId)
            .firstOrNull;
        return AsyncData(
          band == null ? null : (band: band, concertTitle: detail.title),
        );
      },
      // 세션 scope가 바뀌면 같은 scope의 canonical 조회를 사용한다.
      dependencies: [concertDetailProvider, concertParticipantsProvider],
    );

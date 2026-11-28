import 'concert_detail.dart';
import 'concert_status.dart';

/// GET 공연의 서버 권한만 사용한다. 대표자라는 이유로 주최 권한을 추정하지 않는다.
class ConcertAccess {
  const ConcertAccess(this.detail);

  final ConcertDetail detail;

  bool get canEdit => detail.myBandIds.isNotEmpty;
  bool get canManage => canEdit && detail.myPermissions.isHostLeader;
  bool get canDelete =>
      canManage &&
      (detail.status == ConcertStatus.beforeRecruit ||
          detail.status == ConcertStatus.recruiting);

  bool canRemoveBand(int bandId) => canManage && bandId != detail.hostBandId;
}

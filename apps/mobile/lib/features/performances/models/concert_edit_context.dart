import 'concert_edit_values.dart';

/// 상세 화면이 AppRoutes.showEditOf(id)에 extra로 전달하는 계약.
/// reload는 같은 공연의 전체 값·version·현재 세션 권한을 다시 조회한다.
class ConcertEditContext {
  ConcertEditContext({
    required this.concertId,
    required this.snapshot,
    required this.reload,
  }) {
    if (concertId <= 0) throw ArgumentError.value(concertId, 'concertId');
  }

  final int concertId;
  final ConcertEditSnapshot snapshot;
  final Future<ConcertEditSnapshot> Function() reload;
}

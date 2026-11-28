import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/app/routes.dart';

/// `:name` 자리를 값으로 바꾼다. GoRoute가 경로를 맞추는 방식과 같다.
String fill(String pattern, Map<String, String> params) =>
    pattern.replaceAllMapped(RegExp(r':(\w+)'), (m) => params[m[1]]!);

void main() {
  const ids = {
    'postId': 'p1',
    'roomId': 'r1',
    'showId': 's1',
    'scheduleId': 'sc1',
    'bandId': 'b1',
  };

  test('이동용 함수는 같은 이름의 경로 상수를 채운 값과 같다', () {
    final cases = {
      AppRoutes.recruitDetail: AppRoutes.recruitDetailOf('p1'),
      AppRoutes.chatRoom: AppRoutes.chatRoomOf('r1'),
      AppRoutes.chatMembers: AppRoutes.chatMembersOf('r1'),
      AppRoutes.show: AppRoutes.showOf('s1'),
      AppRoutes.showEdit: AppRoutes.showEditOf('s1'),
      AppRoutes.showFeedNew: AppRoutes.showFeedNewOf('s1'),
      AppRoutes.showFeedPost: AppRoutes.showFeedPostOf('s1', 'p1'),
      AppRoutes.showScheduleNew: AppRoutes.showScheduleNewOf('s1'),
      AppRoutes.showSchedule: AppRoutes.showScheduleOf('s1', 'sc1'),
      AppRoutes.showSetlist: AppRoutes.showSetlistOf('s1', 'b1'),
      AppRoutes.showBand: AppRoutes.showBandOf('s1', 'b1'),
      AppRoutes.showRoles: AppRoutes.showRolesOf('s1'),
      AppRoutes.showAccountOwner: AppRoutes.showAccountOwnerOf('s1'),
      AppRoutes.showEntry: AppRoutes.showEntryOf('s1'),
      AppRoutes.showEntrySearch: AppRoutes.showEntrySearchOf('s1'),
      AppRoutes.band: AppRoutes.bandOf('b1'),
      AppRoutes.bandEdit: AppRoutes.bandEditOf('b1'),
      AppRoutes.bandMembers: AppRoutes.bandMembersOf('b1'),
    };

    cases.forEach((pattern, built) {
      expect(built, fill(pattern, ids), reason: pattern);
    });
  });
}

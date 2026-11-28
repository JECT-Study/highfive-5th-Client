/// 경로 문자열은 여기서만 정의한다. View는 자기 경로를 모른다.
/// 아무것도 import하지 않는 상수 파일이다. 화면 연결(`GoRoute`)은 `router.dart`.
/// 전체 지도와 Figma 화면 대응은 `docs/mobile-architecture.md` 11절.
/// 상수는 미리 합의해 두고, `GoRoute`는 그 화면을 만들 때 `router.dart`에 등록한다.
/// `:id`가 있는 경로는 상수(GoRoute용)와 함수(이동용)를 같이 둔다.
abstract final class AppRoutes {
  // 앱 시작: 저장된 세션을 읽는 동안만 보인다
  static const splash = '/splash';

  // 인증·온보딩 (로그인 전)
  static const login = '/login';
  static const terms = '/terms';
  // 약관 상세. 로그인 화면의 약관 동의 시트 위에 쌓는다 (push).
  static const termsDetail = '/terms/:termId';
  static String termsDetailOf(int termId) => '/terms/$termId';
  static const signup = '/signup';
  static const onboardingProfile = '/onboarding/profile';
  static const onboardingBandNew = '/onboarding/band/new';
  static const onboardingBandJoin = '/onboarding/band/join';

  // 하단 탭
  static const home = '/home';
  static const recruit = '/recruit';
  static const chat = '/chat';
  static const my = '/my';

  // 팀 모집
  static const recruitSearch = '/recruit/search';
  static const recruitNew = '/recruit/new';
  static const recruitDetail = '/recruit/:postId';
  static String recruitDetailOf(String postId) => '/recruit/$postId';

  // 채팅
  static const chatRoom = '/chat/:roomId';
  static String chatRoomOf(String roomId) => '/chat/$roomId';
  static const chatMembers = '/chat/:roomId/members';
  static String chatMembersOf(String roomId) => '/chat/$roomId/members';

  // 마이·설정·알림
  static const myProfileEdit = '/my/profile/edit';
  static const settings = '/settings';
  static const notifications = '/notifications';

  // 합동공연
  static const showNew = '/shows/new';
  static const showNewPlace = '/shows/new/place';
  static const show = '/shows/:showId';
  static String showOf(String showId) => '/shows/$showId';
  static const showEdit = '/shows/:showId/edit';
  static String showEditOf(String showId) => '/shows/$showId/edit';
  static const showFeedNew = '/shows/:showId/feed/new';
  static String showFeedNewOf(String showId) => '/shows/$showId/feed/new';
  static const showFeedPost = '/shows/:showId/feed/:postId';
  static String showFeedPostOf(String showId, String postId) =>
      '/shows/$showId/feed/$postId';
  static const showScheduleNew = '/shows/:showId/schedule/new';
  static String showScheduleNewOf(String showId) =>
      '/shows/$showId/schedule/new';
  static const showSchedule = '/shows/:showId/schedule/:scheduleId';
  static String showScheduleOf(String showId, String scheduleId) =>
      '/shows/$showId/schedule/$scheduleId';
  static const showSetlist = '/shows/:showId/setlist/:bandId';
  static String showSetlistOf(String showId, String bandId) =>
      '/shows/$showId/setlist/$bandId';
  // 정보 탭 참여 밴드에서 여는 밴드 프로필 (읽기 전용). 밴드 기능의 /bands/:bandId 화면이 생기면 그쪽으로 옮긴다.
  static const showBand = '/shows/:showId/bands/:bandId';
  static String showBandOf(String showId, String bandId) =>
      '/shows/$showId/bands/$bandId';
  static const showRoles = '/shows/:showId/roles';
  static String showRolesOf(String showId) => '/shows/$showId/roles';
  static const showAccountOwner = '/shows/:showId/account-owner';
  static String showAccountOwnerOf(String showId) =>
      '/shows/$showId/account-owner';
  static const showEntry = '/shows/:showId/entry';
  static String showEntryOf(String showId) => '/shows/$showId/entry';
  static const showEntrySearch = '/shows/:showId/entry/search';
  static String showEntrySearchOf(String showId) =>
      '/shows/$showId/entry/search';

  // 밴드
  static const band = '/bands/:bandId';
  static String bandOf(String bandId) => '/bands/$bandId';
  static const bandEdit = '/bands/:bandId/edit';
  static String bandEditOf(String bandId) => '/bands/$bandId/edit';
  static const bandMembers = '/bands/:bandId/members';
  static String bandMembersOf(String bandId) => '/bands/$bandId/members';

  // dev 빌드 전용 (prod 라우터에는 등록하지 않는다)
  static const devWidgets = '/dev/widgets';
}

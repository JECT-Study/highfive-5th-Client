import 'package:flutter/material.dart';

import '../features/chat/presentation/views/chat_list_view.dart';
import '../features/home/presentation/views/home_view.dart';
import '../features/my_page/presentation/views/my_page_view.dart';
import '../features/recruitments/presentation/views/recruitment_list_view.dart';
import '../shared/theme/app_spacing.dart';
import '../shared/theme/app_theme.dart';
import '../shared/theme/app_typography.dart';
import '../shared/widgets/app_bottom_nav_bar.dart';
import 'concert_edit_preview.dart';
import 'env.dart';
import 'main_shell.dart';

/// release/profile 또는 prod에서 별도 entrypoint를 잘못 선택해도 실행하지 않는다.
void requireOfflinePreview({required Flavor flavor, required bool debug}) {
  if (flavor != Flavor.dev || !debug) {
    throw UnsupportedError('오프라인 미리보기는 dev/debug에서만 실행할 수 있습니다.');
  }
}

/// 실제 View들을 재사용하지만 인증·저장소·API를 연결하지 않는 별도 앱 루트.
class OfflinePreviewApp extends StatelessWidget {
  const OfflinePreviewApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'highfive 오프라인 미리보기',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    builder: (context, child) => MediaQuery.withNoTextScaling(
      child: Banner(
        message: 'OFFLINE DEV',
        location: BannerLocation.topEnd,
        child: child!,
      ),
    ),
    home: const _PreviewTabs(),
  );
}

class _PreviewTabs extends StatefulWidget {
  const _PreviewTabs();

  @override
  State<_PreviewTabs> createState() => _PreviewTabsState();
}

class _PreviewTabsState extends State<_PreviewTabs> {
  int _index = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '오프라인 화면 미리보기 · 실제 로그인 아님',
                  style: context.textStyles.body1Medium,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    key: const ValueKey('offlinePreview_concertEdit'),
                    onPressed: () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (context) => ConcertEditPreview(
                          onClose: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                    child: const Text('공연 정보 수정 미리보기'),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: IndexedStack(
              index: _index,
              children: [
                const HomeView(),
                const RecruitmentListView(),
                const ChatListView(),
                MyPageView(
                  onSignOut: () => showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('오프라인 미리보기예요'),
                      content: const Text('실제 로그인 상태와 저장된 세션은 바꾸지 않아요.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('미리보기 계속'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: AppBottomNavBar(
      items: MainShell.tabs,
      currentIndex: _index,
      onTap: (index) => setState(() => _index = index),
    ),
  );
}

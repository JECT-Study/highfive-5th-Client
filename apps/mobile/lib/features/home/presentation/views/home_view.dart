import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/home/home_action_button.dart';

/// 하단 탭 홈 첫 화면. 지금은 참여 중인 공연이 없을 때(Figma `홈-처음/공연없음` 2217:122923)의
/// 위쪽 문구와 바로가기 버튼만 그린다. 밴드 카드·새 공고·공연 상태별 카드는 각 기능 작업에서 채운다.
///
/// 공연 만들기·팀 모집은 다른 기능이라 이 화면이 직접 열지 않고 라우터가 콜백으로 연결한다.
class HomeView extends StatelessWidget {
  const HomeView({
    super.key,
    required this.onCreateConcert,
    required this.onFindRecruitments,
  });

  /// "공연 열고 팀 모집하기". 라우터가 주최 밴드 선택 → 공연 만들기로 연결한다.
  final VoidCallback onCreateConcert;

  /// "모집 중인 공연 찾기". 라우터가 팀 모집 탭으로 연결한다.
  final VoidCallback onFindRecruitments;

  static const createConcertKey = ValueKey('home_createConcert');
  static const findRecruitmentsKey = ValueKey('home_findRecruitments');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x5,
            AppSpacing.x3_5,
            AppSpacing.x5,
            AppSpacing.x5,
          ),
          children: [
            Text(
              '함께 무대에 오를 밴드를 찾고,\n티켓까지 한 번에 팔아요',
              style: context.textStyles.headBold.copyWith(
                fontSize: _Draft.headlineSize,
                height: _Draft.headlineHeight,
                color: context.colors.labelNormal,
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
            Row(
              spacing: AppSpacing.x2,
              children: [
                Expanded(
                  child: HomeActionButton(
                    key: createConcertKey,
                    label: '공연 열고\n팀 모집하기',
                    onPressed: onCreateConcert,
                  ),
                ),
                Expanded(
                  child: HomeActionButton(
                    key: findRecruitmentsKey,
                    label: '모집 중인\n공연 찾기',
                    type: HomeActionButtonType.search,
                    onPressed: onFindRecruitments,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Figma 홈 화면 값 중 토큰에 없는 것 (docs/design-tokens.md "Figma 화면과 어긋난 값").
/// 디자이너가 확인하면 토큰으로 바꾸고 지운다.
abstract final class _Draft {
  static const headlineSize = 22.0; // 위쪽 문구 22 Bold (가장 가까운 토큰 Head(B) 24)
  static const headlineHeight = 1.4; // 위쪽 문구 행간 (Head(B)는 1.3)
}

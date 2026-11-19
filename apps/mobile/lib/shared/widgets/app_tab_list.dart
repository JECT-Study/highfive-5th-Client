import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_component_tokens.dart';
import '../theme/app_typography.dart';

/// Figma `TabList`. 화면 안 상단 탭 (예: 합동공연 페이지의 정보·피드·일정·티켓 관리).
/// 고른 탭은 굵은 글자 + 아래 진한 선. 탭 전환과 내용 교체는 화면이 [onSelected]로 한다.
class AppTabList extends StatelessWidget {
  const AppTabList({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textStyles = context.textStyles;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.lineStrong)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTabListTokens.paddingX,
        ),
        child: Row(
          children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == selectedIndex,
                  child: InkWell(
                    onTap: () => onSelected(i),
                    child: Container(
                      height: AppTabListTokens.height,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: i == selectedIndex
                                ? colors.labelStrong
                                : colors.backgroundNormal.withValues(alpha: 0),
                            width: AppTabListTokens.indicatorHeight,
                          ),
                        ),
                      ),
                      child: Text(
                        labels[i],
                        maxLines: 1,
                        style: i == selectedIndex
                            ? textStyles.body1Bold.copyWith(
                                color: colors.labelStrong,
                              )
                            : textStyles.body1Regular.copyWith(
                                color: colors.interactionInactive,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

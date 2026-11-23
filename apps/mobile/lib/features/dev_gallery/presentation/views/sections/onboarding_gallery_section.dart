import 'package:flutter/material.dart';

import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_spacing.dart';
import '../../../../../shared/widgets/app_text_field.dart';
import '../../../../../shared/widgets/onboarding/onboarding_option_card.dart';
import '../../../../../shared/widgets/onboarding/onboarding_popup.dart';
import 'gallery_item.dart';

/// 위젯 모음의 온보딩 영역. `shared/widgets/onboarding/` 위젯을 Figma 온보딩 섹션의 문구로 보여 준다.
class OnboardingGallerySection extends StatelessWidget {
  const OnboardingGallerySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GalleryItem(
          code: 'OnboardingOptionCard',
          figma: 'Onboarding (Property 1 = Default · Code)',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              const GalleryCaption('Property 1 = Default → type: create'),
              OnboardingOptionCard(
                title: '밴드 만들기',
                description: '우리 팀 대표자라면 여기서 시작하세요.',
                onTap: () {},
              ),
              const GalleryCaption(
                'Property 1 = Code → type: code + codeField(AppTextField)',
              ),
              const OnboardingOptionCard(
                type: OnboardingOptionType.code,
                title: '코드로 합류하기',
                description: '대표자에게 받은 코드를 입력해 주세요.',
                codeField: AppTextField(hintText: '4자리 코드를 입력해 주세요.'),
              ),
            ],
          ),
        ),
        GalleryItem(
          code: 'OnboardingPopup',
          figma: 'popup',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.x3,
            children: [
              const GalleryCaption('다이얼로그로 뜬 모습처럼 어두운 바탕 위에 둔다'),
              ColoredBox(
                color: context.colors.materialDimmer,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.x4),
                  child: OnboardingPopup(
                    title: '소음공장이 만들어졌어요',
                    message: '팀원들과 함께 첫 공연을 준비해요',
                    codeLabel: '팀원 초대 방 코드',
                    code: 'A7K2',
                    memberLabel: '팀원 2명',
                    copyLabel: '코드복사',
                    onCopyPressed: () {},
                    shareLabel: '공유하기',
                    onSharePressed: () {},
                    hint: "마이페이지의 '내 밴드'에서도 다시 코드를 볼 수 있어요.",
                    confirmLabel: '다음',
                    onConfirmPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

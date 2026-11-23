import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../view_models/login_view_model.dart';

/// 로그인 화면 (Figma `계정-회원가입`, node `1372:6594`).
/// 디자이너 확인 전이라 토큰에 없는 시안 값도 [_Draft]에 모아 시안과 똑같이 맞춘다.
/// 소셜 로그인 SDK를 붙이기 전이라 세 버튼 모두 임시 토큰으로 로그인한다 (`AuthService`).
class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  static const kakaoButtonKey = ValueKey('login_kakao');
  static const appleButtonKey = ValueKey('login_apple');
  static const googleButtonKey = ValueKey('login_google');
  static const introKey = ValueKey('login_intro');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loginViewModelProvider).isLoading;
    void login() => ref.read(loginViewModelProvider.notifier).login();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          // 시안처럼 소개는 위에, 버튼은 아래에 고정하고 남는 높이는 그 사이로 간다.
          // 화면이 짧으면 로고 위 여백부터 줄이고, 소개 ↔ 버튼 사이는 최소 x8을 지킨다.
          // 그래도 모자라면 스크롤한다.
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x5,
                  ),
                  child: Column(
                    children: [
                      const Expanded(
                        child: Column(
                          children: [
                            Flexible(
                              child: _ShrinkableSpace(
                                maxHeight: _Draft.introTop,
                              ),
                            ),
                            _Intro(key: introKey),
                            // 남는 높이는 이 아래(버튼 위)에 생긴다.
                            SizedBox(height: AppSpacing.x8),
                          ],
                        ),
                      ),
                      _DraftButtonTheme(
                        child: Column(
                          children: [
                            _LoginButton(
                              key: kakaoButtonKey,
                              label: '카카오톡으로 계속하기',
                              variant: AppButtonVariant.fill,
                              loading: loading,
                              onPressed: login,
                            ),
                            const SizedBox(height: AppSpacing.x2_5),
                            _LoginButton(
                              key: appleButtonKey,
                              label: 'Apple로 계속하기',
                              variant: AppButtonVariant.weak,
                              loading: loading,
                              onPressed: login,
                            ),
                            const SizedBox(height: AppSpacing.x2_5),
                            _LoginButton(
                              key: googleButtonKey,
                              label: 'Google로 계속하기',
                              variant: AppButtonVariant.weak,
                              loading: loading,
                              onPressed: login,
                            ),
                          ],
                        ),
                      ),
                      // 시안처럼 버튼은 아래에서 고정 거리에 둔다.
                      SizedBox(
                        height: _Draft.buttonsBottom,
                        child: Column(
                          children: [
                            const SizedBox(height: _Draft.helpGap),
                            // 누르면 어디로 갈지 정해지지 않아 아직 글자만 둔다.
                            Text(
                              '로그인에 문제가 있으신가요?',
                              textAlign: TextAlign.center,
                              style: context.textStyles.body1Medium.copyWith(
                                color: _Draft.gray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Figma 로그인 시안 값 중 토큰과 다른 것. 디자이너 확인 전 임시로 시안에 맞춘다.
/// 확정되면 토큰으로 옮기거나(docs/design-tokens.md 2절) 토큰 값으로 바꾸고 이 클래스를 지운다.
/// 시안 값과 토큰 값 비교는 docs/design-tokens.md "Figma 화면과 어긋난 값 → 로그인".
abstract final class _Draft {
  static const ink = Color(0xFF1A1A1A); // 카카오 버튼 바탕, Apple·Google 글자
  static const buttonBorder = Color(0xFFC5C5C5); // Apple·Google 버튼 테두리
  static const gray = Color(0xFF7F7F7F); // 부제목·도움말 글자
  static const titleSize = 26.0;
  static const subtitleLineHeight = 1.5;
  static const logoGap = 28.0; // 로고 ↔ 제목
  static const iconSize = 26.0; // 버튼 안 브랜드 로고
  static const introTop = 119.0; // 상태 표시줄 아래 → 로고 (시안 top 163 - 44)
  static const helpGap = 29.0; // 마지막 버튼 → 도움말 글자 위
  static const buttonsBottom = 110.0; // 마지막 버튼 → 홈 인디케이터 위 (시안 144 - 34)
}

/// 로그인 버튼만 시안 색·글자 굵기로 그리도록 AppButton이 읽는 토큰을 이 아래에서만 바꾼다.
/// fill 바탕(label.strong)·weak 글자(label.neutral) → [_Draft.ink], weak 테두리(line.neutral) → [_Draft.buttonBorder],
/// 버튼 글자 Title-2(B)·Title-2(R) → Title-2(SB).
class _DraftButtonTheme extends StatelessWidget {
  const _DraftButtonTheme({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyles = context.textStyles;
    return Theme(
      data: theme.copyWith(
        extensions: [
          ...theme.extensions.values,
          context.colors.copyWith(
            labelStrong: _Draft.ink,
            labelNeutral: _Draft.ink,
            lineNeutral: _Draft.buttonBorder,
          ),
          textStyles.copyWith(
            title2Bold: textStyles.title2SemiBold,
            title2Regular: textStyles.title2SemiBold,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// [maxHeight]까지 차지하고 자리가 모자라면 0까지 줄어드는 빈칸. `Flexible` 안에 둔다.
/// 크기 계산(intrinsic)에서는 0으로 잡혀, 짧은 화면에서 스크롤보다 이 칸이 먼저 줄어든다.
class _ShrinkableSpace extends StatelessWidget {
  const _ShrinkableSpace({required this.maxHeight});

  final double maxHeight;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(maxHeight: maxHeight),
    child: const SizedBox(height: double.infinity),
  );
}

/// 로고와 소개 문구.
class _Intro extends StatelessWidget {
  const _Intro({super.key});

  /// Figma Logo 자리 크기.
  static const _logoSize = 100.0;

  @override
  Widget build(BuildContext context) {
    final textStyles = context.textStyles;
    return Column(
      children: [
        // 로고가 나오기 전 자리 표시 (Figma도 회색 상자).
        SizedBox.square(
          dimension: _logoSize,
          child: ColoredBox(color: context.colors.lineStrong),
        ),
        const SizedBox(height: _Draft.logoGap),
        Text(
          '음악이 통하는 순간\n우리는 한 팀!',
          textAlign: TextAlign.center,
          style: textStyles.head.copyWith(
            fontSize: _Draft.titleSize,
            fontWeight: FontWeight.w700,
            color: context.colors.labelStrong,
          ),
        ),
        const SizedBox(height: AppSpacing.x3),
        Text(
          '함께 연주할 동료를 만나고\n잊지 못할 순간을 만들어 보세요.',
          textAlign: TextAlign.center,
          style: textStyles.body1Medium.copyWith(
            height: _Draft.subtitleLineHeight,
            color: _Draft.gray,
          ),
        ),
      ],
    );
  }
}

/// 가로를 채우는 소셜 로그인 버튼. 하나가 로딩이면 모두 눌리지 않는다.
class _LoginButton extends StatelessWidget {
  const _LoginButton({
    super.key,
    required this.label,
    required this.variant,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final AppButtonVariant variant;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        label: label,
        variant: variant,
        loading: loading,
        onPressed: onPressed,
        // 브랜드 로고가 나오기 전 자리 표시 (Figma도 회색 상자).
        icon: ColoredBox(color: context.colors.lineStrong),
        iconSize: _Draft.iconSize,
        iconGap: AppSpacing.x2_5,
      ),
    );
  }
}

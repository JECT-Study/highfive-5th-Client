import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_spacing.dart';
import '../../../../shared/theme/app_typography.dart';
import '../../../../shared/widgets/app_button.dart';
import '../view_models/login_view_model.dart';

/// 로그인 화면 (Figma `계정-회원가입`).
/// 시안과 다른 값은 공통 컴포넌트·토큰을 따른다. 목록은 docs/design-tokens.md "Figma 화면과 어긋난 값".
/// 소셜 로그인 SDK를 붙이기 전이라 세 버튼 모두 임시 토큰으로 로그인한다 (`AuthService`).
class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  static const kakaoButtonKey = ValueKey('login_kakao');
  static const appleButtonKey = ValueKey('login_apple');
  static const googleButtonKey = ValueKey('login_google');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(loginViewModelProvider).isLoading;
    void login() => ref.read(loginViewModelProvider.notifier).login();

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          // 작은 화면에서는 넘치지 않게 스크롤하고, 큰 화면에서는 시안처럼 위·가운데·아래로 나눠 둔다.
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
                      const Spacer(flex: 6),
                      const _Intro(),
                      const Spacer(flex: 4),
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
                      const SizedBox(height: AppSpacing.x6),
                      // 누르면 어디로 갈지 정해지지 않아 아직 글자만 둔다.
                      Text(
                        '로그인에 문제가 있으신가요?',
                        textAlign: TextAlign.center,
                        style: context.textStyles.body1Medium.copyWith(
                          color: context.colors.labelAlternative,
                        ),
                      ),
                      const Spacer(flex: 3),
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

/// 로고와 소개 문구.
class _Intro extends StatelessWidget {
  const _Intro();

  /// Figma Logo 자리 크기.
  static const _logoSize = 100.0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 로고가 나오기 전 자리 표시 (Figma도 회색 상자).
        SizedBox.square(
          dimension: _logoSize,
          child: ColoredBox(color: context.colors.lineStrong),
        ),
        const SizedBox(height: AppSpacing.x6),
        Text(
          '음악이 통하는 순간\n우리는 한 팀!',
          textAlign: TextAlign.center,
          style: context.textStyles.head.copyWith(
            color: context.colors.labelStrong,
          ),
        ),
        const SizedBox(height: AppSpacing.x3),
        Text(
          '함께 연주할 동료를 만나고\n잊지 못할 순간을 만들어 보세요.',
          textAlign: TextAlign.center,
          style: context.textStyles.body1Medium.copyWith(
            color: context.colors.labelAlternative,
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
        // 브랜드 로고가 나오기 전 자리 표시 (Figma도 회색 상자). 크기는 AppButton 아이콘 칸이 정한다.
        icon: ColoredBox(color: context.colors.lineStrong),
      ),
    );
  }
}

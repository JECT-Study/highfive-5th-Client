import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 화면 데이터를 기다리는 동안 가운데에 보이는 진행 표시 (pr-checklist A5).
/// 어느 화면에서나 같은 모양으로 쓰고, 화면마다 새로 그리지 않는다.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.colors.labelAlternative),
    );
  }
}

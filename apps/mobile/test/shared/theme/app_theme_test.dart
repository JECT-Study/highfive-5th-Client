import 'package:flutter_test/flutter_test.dart';
import 'package:highfive/shared/theme/app_colors.dart';
import 'package:highfive/shared/theme/app_theme.dart';

void main() {
  test('글자 스타일의 색은 textPrimary 토큰이다', () {
    final t = AppTheme.light.textTheme;

    for (final style in [
      t.headlineSmall,
      t.titleLarge,
      t.bodyMedium,
      t.bodySmall,
    ]) {
      expect(style?.color, AppColors.light.textPrimary);
    }
  });
}

import 'package:flutter_test/flutter_test.dart';

import '../../tool/check_imports.dart' as checker;

const _views = 'features/auth/presentation/views/v.dart';

void main() {
  // (설명, from, source, 위반이어야 하는가)
  const cases = <(String, String, String, bool)>[
    (
      '기능에서 app을 import하면 막는다',
      _views,
      "import '../../../../app/router.dart';",
      true,
    ),
    (
      '다른 기능의 service는 막는다',
      _views,
      "import '../../../payments/data/services/s.dart';",
      true,
    ),
    (
      '다른 기능의 dto는 막는다',
      _views,
      "import '../../../payments/data/dto/d.dart';",
      true,
    ),
    (
      '다른 기능의 repository는 허용한다',
      _views,
      "import '../../../payments/data/repositories/r.dart';",
      false,
    ),
    (
      '다른 기능의 model은 허용한다',
      _views,
      "import '../../../payments/models/m.dart';",
      false,
    ),
    (
      'View가 repository를 직접 쓰면 막는다',
      _views,
      "import '../../data/repositories/r.dart';",
      true,
    ),
    (
      'ViewModel이 service를 직접 쓰면 막는다',
      'features/auth/presentation/view_models/vm.dart',
      "import '../../data/services/s.dart';",
      true,
    ),
    (
      'ViewModel은 repository를 쓸 수 있다',
      'features/auth/presentation/view_models/vm.dart',
      "import '../../data/repositories/r.dart';",
      false,
    ),
    (
      'repository가 presentation을 쓰면 막는다',
      'features/auth/data/repositories/r.dart',
      "import '../../presentation/providers/p.dart';",
      true,
    ),
    (
      'service가 repository를 쓰면 막는다',
      'features/auth/data/services/s.dart',
      "import '../repositories/r.dart';",
      true,
    ),
    (
      'model이 core를 쓰면 막는다',
      'features/auth/models/m.dart',
      "import '../../../core/network/dio_client.dart';",
      true,
    ),
    (
      'model이 flutter를 쓰면 막는다',
      'features/auth/models/m.dart',
      "import 'package:flutter/material.dart';",
      true,
    ),
    (
      'View는 flutter를 쓸 수 있다',
      _views,
      "import 'package:flutter/material.dart';",
      false,
    ),
    (
      'shared가 features를 쓰면 막는다',
      'shared/theme/t.dart',
      "import '../../features/auth/models/m.dart';",
      true,
    ),
    (
      'core가 shared를 쓰면 막는다',
      'core/network/n.dart',
      "import '../../shared/theme/app_colors.dart';",
      true,
    ),
    (
      'export도 검사한다',
      'features/auth/models/m.dart',
      "export '../data/dto/d.dart';",
      true,
    ),
    (
      '조건부 import의 if 쪽 URI도 검사한다',
      'features/auth/data/services/s.dart',
      "import 'stub.dart' if (dart.library.io) 'package:highfive/app/env.dart';",
      true,
    ),
    (
      '여러 줄에 걸친 import도 검사한다',
      _views,
      "import\n    '../../../../app/router.dart';",
      true,
    ),
    (
      '블록 주석 안의 import는 무시한다',
      _views,
      "/*\nimport '../../../../app/router.dart';\n*/",
      false,
    ),
    (
      '지시문 안 주석의 URI는 무시한다',
      _views,
      "import '../../../payments/models/m.dart' // '../../../../app/router.dart'\n    ;",
      false,
    ),
  ];

  for (final (name, from, source, isViolation) in cases) {
    test(name, () {
      expect(checker.findViolations(from, source).isNotEmpty, isViolation);
    });
  }

  test('위반 줄 번호는 지시문이 시작한 줄이다', () {
    const source =
        "import 'package:flutter/material.dart';\n\nimport '../../../../app/router.dart';";
    final found = checker.findViolations(_views, source);

    expect(found.map((v) => v.line), [3]);
  });

  test('문자열 안의 import 줄은 무시한다', () {
    const source = "const s = '''\nimport '../../../../app/router.dart';\n''';";

    expect(checker.findViolations(_views, source), isEmpty);
  });
}

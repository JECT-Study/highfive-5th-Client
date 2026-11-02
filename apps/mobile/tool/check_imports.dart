// lib/ 안 import가 docs/mobile-architecture.md 2절의 방향 규칙을 지키는지 검사한다.
// 실행: fvm dart run tool/check_imports.dart   (위반이 있으면 종료 코드 1)
import 'dart:io';

final _importPattern = RegExp(r'''^\s*(?:import|export)\s+['"]([^'"]+)['"]''');

void main() {
  final libDir = Directory('lib');
  if (!libDir.existsSync()) {
    stderr.writeln('lib/ 폴더가 없다. apps/mobile 에서 실행한다.');
    exit(2);
  }
  final files = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  final violations = <String>[];
  for (final file in files) {
    final from = _libRelative(file.path);
    for (final (lineNo, line) in file.readAsLinesSync().indexed) {
      final match = _importPattern.firstMatch(line);
      if (match == null) continue;
      final to = _resolve(from, match.group(1)!);
      if (to == null) continue;
      final reason = _violation(from, to);
      if (reason != null) {
        violations.add('${file.path}:${lineNo + 1}  → $to\n    $reason');
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('import 방향 OK (${files.length} files)');
    return;
  }
  stderr.writeln(
    'import 방향 위반 ${violations.length}건 (docs/mobile-architecture.md 2절)',
  );
  violations.forEach(stderr.writeln);
  exit(1);
}

String _libRelative(String path) {
  final idx = path.indexOf('lib/');
  return path.substring(idx + 4).replaceAll(r'\', '/');
}

/// `package:highfive/...` 와 상대 경로만 lib 기준 경로로 바꾼다. 그 외(dart:, 다른 패키지)는 무시.
String? _resolve(String from, String uri) {
  const pkg = 'package:highfive/';
  if (uri.startsWith(pkg)) return uri.substring(pkg.length);
  if (uri.contains(':')) return null;
  final parts = from.split('/')..removeLast();
  for (final seg in uri.split('/')) {
    if (seg == '..') {
      if (parts.isEmpty) return null;
      parts.removeLast();
    } else if (seg != '.') {
      parts.add(seg);
    }
  }
  return parts.join('/');
}

String? _violation(String from, String to) {
  final f = _Layer.of(from);
  final t = _Layer.of(to);
  if (f == null || t == null) return null;

  return switch (f.name) {
    'core' when t.name != 'core' =>
      'core는 ${t.name}을 import하지 않는다 (core는 맨 아래층)',
    'shared' when t.name == 'app' || t.name == 'features' =>
      'shared는 ${t.name}을 import하지 않는다',
    'features' => _featureViolation(f, t),
    _ => null,
  };
}

String? _featureViolation(_Layer f, _Layer t) {
  if (t.name == 'app') {
    return 'features는 app을 import하지 않는다 (연결 Provider는 presentation/providers 에)';
  }
  if (t.name != 'features') return null;
  if (f.feature != t.feature) {
    if (t.sub == 'presentation') {
      return '다른 기능의 presentation을 import하지 않는다 (data/repositories·models 계약만)';
    }
    return null;
  }
  if (f.sub.startsWith('data') && t.sub == 'presentation') {
    return 'data는 presentation을 모른다';
  }
  if (f.sub == 'models' && t.sub != 'models') {
    return 'models는 패키지만 import한다';
  }
  if (f.sub == 'data/services' && t.sub == 'data/repositories') {
    return 'services는 repositories를 import하지 않는다';
  }
  return null;
}

class _Layer {
  const _Layer(this.name, {this.feature = '', this.sub = ''});

  final String name;
  final String feature;
  final String sub;

  static _Layer? of(String path) {
    final parts = path.split('/');
    switch (parts.first) {
      case 'app':
      case 'core':
      case 'shared':
        return _Layer(parts.first);
      case 'features':
        if (parts.length < 3) return null;
        final sub = parts[2] == 'data' && parts.length > 4
            ? 'data/${parts[3]}'
            : parts[2];
        return _Layer('features', feature: parts[1], sub: sub);
      default:
        return null;
    }
  }
}
